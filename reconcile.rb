#!/bin/env ruby

def system_cmd (cmd, print_output=false)
  puts "Running cmd: #{cmd}"
  output = `#{cmd}`.split("\n")
  if print_output
    puts output
  else
    #puts output
  end
  #raise(StandardError, "Cmd #{cmd} failed") unless $?.success?
  [output, $?.success?]
end

def get_rev_list(dir, opts='--no-merges')
  rev_list=[]
  Dir.chdir(dir) do
    rev_list=`git rev-list #{opts} HEAD`.split("\n")
  end
  rev_list
end

def checkout(dir, commit, opts='')
#  puts "Checking out upstream: #{commit}"
  Dir.chdir(dir) do
    output=`git checkout #{commit} #{opts}`
    #puts output
  end
end

def clone(dir, repo)
  puts output=`git clone #{repo} #{dir}`
end

def add_remote(dir, repo, name)
  Dir.chdir(dir) do
    output=`git remote add #{name} #{repo}`
    output=`git fetch #{name}`
  end
end

#
# find the commit that has the same content
#
def find_common_commit(downstream_dir, upstream_dir, rev_list_down, rev_list_up)

  # start with first commit from downstream
  #rev_list_down.reverse.each do |ref|
  output_size={}
  # NOTE: always just check the last (oldest) commit from downstream.
  # you could iterate through them all, but it would change form O(n) to O(n2)
  # I was thinking it would be annoyingly slow, so I didn't even bother trying
  # rev_list_down.each do |ref|
  ref = rev_list_down.last
    # checkout the last commit from downstream
    checkout(downstream_dir, ref)
    # iterate throuug all upstream commits
    rev_list_up.each do |ref2|
      # checkout upstream code based on that commit
      checkout(upstream_dir, ref2)
      # run the recursive diff
      out = system_cmd("diff -r --exclude=.svn --exclude=.git #{upstream_dir} #{downstream_dir}")
      # if return code is true (ie: they match!)
      if out[1]
        puts "Upstream #{ref2} matches downstream #{ref}"
        # return the references that match [downstream, upstream]
        return [ref, ref2]
      else
        output_size[out[0].size] ||= {}
        # if they don't match, save the references, and diff output
        output_size[out[0].size]["#{ref}_#{ref2}"] = out[0]
      end
    end
  #end
  smallest = output_size.keys.sort.first
  puts "the least number of difference found is: #{smallest}"
  puts "we found #{output_size[smallest].size} one repos of this diff size"
  puts "The output from the first one of this size is:\n#{output_size[smallest].values.first.join("\n")}"
  refs=output_size[smallest].keys.first.split('_')
  puts "For refs: #{refs}"
  checkout(downstream_dir, refs[0])
  checkout(upstream_dir, refs[1])
  if output_size[smallest].size == 1
    # if there is only one smallest matching, show the user the diff and ask them if they want
    # to try to rebase anyways
    puts 'Do you want to proceed with rebasing this result?(Yes or No)'
    result = gets
    if result.chomp == 'Yes'
      return refs
    end
  end
  raise "Could not find any common anscestor"
end

#
# take the list of downstream commits that need to be
# applied on top of our selected upstream commit, and
# cherry-pick them one-by-one. It's kind of like a rebase
#
def rebase(dir, downstream_commits, upstream_ref)
  Dir.chdir(dir) do
    # simply checkout upstream ref
    puts `git checkout #{upstream_ref}`
    # for downstream, get a list of the commits newer than matching red
puts downstream_commits.inspect
    downstream_commits.each do |dsc|
      puts `git cherry-pick #{dsc} --allow-empty`
    end
  end
end

def get_dir_name(downstream, upstream)
  name = downstream.split('-').last
  raise("repo names do not match :( #{downstream}|#{upstream}") if name != upstream.split('-').last
  pwd = File.join(Dir.pwd, name)
end

# this method does all of the real operations for
# reconciliation
def fix_repos(downstream, upstream)
  # get the module name ie: nova
  pwd=get_dir_name(downstream, upstream)
  if File.exists?(pwd)
    raise "Please manually clean up old directories: #{name}"
  end
  Dir.mkdir(pwd)
  puts "Working out of directory #{pwd}"

  upstream_dir=File.join(pwd, 'upstream')
  downstream_dir=File.join(pwd, 'downstream')

  # clone the upstream and downstream repos
  clone(downstream_dir, "git://github.com/#{downstream}")
  clone(upstream_dir, "git://github.com/#{upstream}")

  # add write remotes for upstream and downstream to upstream
  # it needs the downstream remote b/c it needs access to it's
  # references to perform the cherry-picks
  # it needs access to the upstream repo to perform the push
  add_remote(upstream_dir, "git@github.com:#{downstream}", 'downstream')
  add_remote(upstream_dir, "git@github.com:#{upstream}", 'upstream')

  # start from origin/master
  # this used to be required b/c I was reusing the same directories for testing
  # it isn't required anymore, but it doesn't hurt to leave it here
  checkout(downstream_dir, 'origin/master')
  checkout(upstream_dir, 'origin/master')

  # get all revisions for upstream downstream
  rev_list_down=get_rev_list(downstream_dir)
  rev_list_up=get_rev_list(upstream_dir)
  puts "UP revs count #{rev_list_up.size}"

  # find the commit that upstream and downstream that has the same contents
  ref_results=find_common_commit(downstream_dir, upstream_dir, rev_list_down, rev_list_up)

  # rebase the downstream commits on upstream via cherry-pick
  rebase(upstream_dir, rev_list_down[0..(rev_list_down.index(ref_results[0])-1)].reverse, ref_results[1])
end

#
# simple method for pushing to svn_git_port branch
# of selected upstream repo
#
def push(downstream, upstream)
  name=get_dir_name(downstream, upstream)
  upstream_dir=File.join(name, 'upstream')
  Dir.chdir(upstream_dir) do
    puts `git checkout -b push`
    puts `git push upstream HEAD:svn_git_port`
  end
end


#
# select your action. You almost always want to reconcile
#

#action = 'push'
action = 'reconcile'

#
# Right now, you just hard-code the hash of repos inline in the file
#
# each hash element is of the form:
#
#   downstream_repo -> upstream_repo
#
# where downstream repos represent the commits that were converted from
# svn and upstream is the upstream repo that has been forked to our jiocloud
# repo.

#
# the whole purpose of this script is to do the following:
#   - go to the oldest/first commit in the downstream repo (this assumes that the
#     initial commit is where downstream got lost from upstream's history
#   - go through each commit in upstream's repo.
#   - for each commit, perform a recursive diff to see if it has the same contents
#     as the oldest commit as downstream
#   - if a commit matches, in the upstream local repo, take all commits after the oldest
#     and from oldest to newest, cherry-pick them on top of the matches upstream commit
#   - if the commit doesn't match, it will print out the commit that matches with the
#     fewest differences (NOTE: to do this is essentially does `diff -r up down | wc -l`
#     which may be problematic, like in cases where entire files are missing)
#   - if will output the best matching commit and ask you if you want to use it to rebase.
#   - last, it asks you if you want to push to the repo. It pushes to the upstream repo and
#     creates a branch called svn_git_port
#
repos = {

# these ones had no issues
#  'jiocloud/jiocloud-nova' => 'jiocloud/puppet-nova',
#  'jiocloud/jiocloud-ceph' => 'jiocloud/puppet-ceph',
#  'jiocloud/jiocloud-cinder' => 'jiocloud/puppet-cinder',
#  'jiocloud/jiocloud-glance' => 'jiocloud/puppet-glance',
#  'jiocloud/jiocloud-horizon' => 'jiocloud/puppet-horizon',
   'jiocloud/jiocloud-neutron' => 'jiocloud/puppet-neutron',
# these ones had issues
#  'jiocloud/jiocloud-keystone' => 'jiocloud/puppet-keystone',
#  'jiocloud/jiocloud-network' => 'jiocloud/attachmentgenie-network',

}

repos.each do |x, y|
  if action == 'reconcile'
    # first try to rebase the repos
    fix_repos(x, y)
    puts 'Do you want to push these changes to svn_git_port branch?(Yes or No)'
    resp = gets
    if resp.chomp == 'Yes'
      # then push to upstream if the users wants you to
      push(x, y)
    end
  elsif action == 'push'
    push(x, y)
  else
    raise "Unexpected action"
  end
end
