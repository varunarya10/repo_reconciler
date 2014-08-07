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
  puts smallest
  puts output_size[smallest].size
  puts output_size[smallest].values.first.join("\n")
  raise "Could not find any common anscesto"
  #puts output_size[output_size.keys.sort.first].inspect
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

def fix_repos(downstream, upstream)
  name = downstream.split('-').last
  raise("repo names do not match :( #{downstream}|#{upstream}") if name != upstream.split('-').last
  time = "#{name}_#{Time.now.strftime("%Y%m%d%H%M%S")}"
  Dir.mkdir(time)

  pwd = File.join(Dir.pwd, time)

  puts "Working out of directory #{pwd}"

  upstream_dir=File.join(pwd, 'upstream')
  downstream_dir=File.join(pwd, 'downstream')

  # clone the repos
  clone(downstream_dir, "git://github.com/#{downstream}")
  clone(upstream_dir, "git://github.com/#{upstream}")

  # add all remotes to repo
  add_remote(upstream_dir, "git://github.com/#{downstream}", 'downstream')
  add_remote(upstream_dir, "git@github.com:#{downstream}", 'upstream')

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


# can you even create repos for things that we are not forking?


# I need to sort this out for the following repos:
#
# 1. account
#  This does not have a repo. Are we afraid of publishing the ssh pub keys?
#  I created jiocloud/puppet-acccount
# 2. add_user_to_group
#  I created jiocloud/puppet-add_user_to_group
# 3. apache -> ../module_source/puppetlabs-apache-1.1.1
#  This has no downstream repo. Is that because it only has an upstream?
# 4. apt -> ../module_source/puppetlabs-apt-1.4.2
# 5. base_packages
# 6. ceph -> ../module_source/puppet-ceph
#    This actually has a module, but I have no idea who upstream is it looks like it came from enovance
# 7. cinder -> ../module_source/puppet-cinder
# 8. concat -> ../module_source/puppetlabs-concat-1.1.0-rc1
# 9. contrail -> ../module_source/contrail-puppet/contrail
# 10. cron
# 11. glance -> ../module_source/puppet-glance
# 12. horizon -> ../module_source/puppet-horizon
# 13. inifile -> ../module_source/puppetlabs-inifile
# 14. jiocloud
# 15 ji ocloud_registration
# 16 keystone -> ../module_source/puppet-keystone
# 17 kvm
# 18 logrotate
# 19 lvm
# 20 memcached -> ../module_source/saz-memcached-2.2.4
# 21 mysql -> ../module_source/puppetlabs-mysql-2.2.3
# 22 network -> ../module_source/attachmentgenie-network-1.0.1
# 23 neutron -> ../module_source/puppet-neutron
# 24 nova -> ../module_source/puppet-nova
# 25 nscd
# 26 ntp -> ../module_source/puppetlabs-ntp-3.0.1
# 27 openstack
# 28 python-django-horizon
# 29 rabbitmq -> ../module_source/puppetlabs-rabbitmq-4.0.0
# 30 resolver
# 31 sethostname
# 32 ssh -> ../module_source/puppet-ssh
# 33 staging -> ../module_source/nanliu-staging-0.4.1
# 34 stdlib -> ../module_source/puppetlabs-stdlib-4.1.0
# 35 sudo -> ../module_source/puppet-sudo/
# 36 sysctl -> ../module_source/puppet-sysctl
# 37 tfile
# 38 timezone
# 39 zeromq
# 40zookeeper -> ../module_source/viirya-zookeeper-0.0.7
#
# I will assume that thigns without symlinks are not foked from an upstream, I expect these to exist as puppet-* in jiocloud
#
#
#

repos = {
  'jiocloud/jiocloud-nova' => 'jiocloud/puppet-nova',
}

repos.each do |x, y|
  fix_repos(x, y)
end
