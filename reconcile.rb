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

def find_common_commit(downstream_dir, upstream_dir, rev_list_down, rev_list_up)

  # start with first commit from downstream
  #rev_list_down.reverse.each do |ref|
  output_size={}
  ref = rev_list_down.last
    checkout(downstream_dir, ref)
    rev_list_up.each do |ref2|
      checkout(upstream_dir, ref2)
      out = system_cmd("diff -r --exclude=.svn --exclude=.git #{upstream_dir} #{downstream_dir}")
      if out[1]
        puts "Upstream #{ref2} matches downstream #{ref}"
        return [ref, ref2]
        exit 0
      else
        output_size[out[0].size] ||= {}
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
    puts 'Do you want to proceed with rebasing this result?(Yes or No)'
    result = gets
    if result.chomp == 'Yes'
      return refs
    end
  end
  raise "Could not find any common anscestor"
end

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

def fix_repos(downstream, upstream)
  pwd=get_dir_name(downstream, upstream)
  if File.exists?(pwd)
    raise "Please manually clean up old directories: #{name}"
  end
  Dir.mkdir(pwd)
  puts "Working out of directory #{pwd}"

  upstream_dir=File.join(pwd, 'upstream')
  downstream_dir=File.join(pwd, 'downstream')

  # clone the repos
  clone(downstream_dir, "git://github.com/#{downstream}")
  clone(upstream_dir, "git://github.com/#{upstream}")

  # add all remotes to repo
  add_remote(upstream_dir, "git@github.com:#{downstream}", 'downstream')
  add_remote(upstream_dir, "git@github.com:#{upstream}", 'upstream')

  # start from origin/master
  checkout(downstream_dir, 'origin/master')
  checkout(upstream_dir, 'origin/master')

  # get all revisions
  rev_list_down=get_rev_list(downstream_dir)
  rev_list_up=get_rev_list(upstream_dir)
  puts "UP revs count #{rev_list_up.size}"

  ref_results=find_common_commit(downstream_dir, upstream_dir, rev_list_down, rev_list_up)

  rebase(upstream_dir, rev_list_down[0..(rev_list_down.index(ref_results[0])-1)].reverse, ref_results[1])
end

def push(downstream, upstream)
  name=get_dir_name(downstream, upstream)
  upstream_dir=File.join(name, 'upstream')
  Dir.chdir(upstream_dir) do
    puts `git checkout -b push`
    puts `git push upstream HEAD:svn_git_port`
  end
end


#action = 'push'
action = 'reconcile'

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
    fix_repos(x, y)
    puts 'Do you want to push these changes to svn_git_port branch?(Yes or No)'
    resp = gets
    if resp.chomp == 'Yes'
      push(x, y)
    end
  elsif action == 'push'
    push(x, y)
  else
    raise "Unexpected action"
  end
end
