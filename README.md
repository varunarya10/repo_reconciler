# intro

This project was created to assist reliance with rebasing their repos against upstream.

The repos were forked from upstream repos without any history, so a large number of repos have
to have the following done to them:

1. figure out what commit the repos were based on
2. rebase the repos based on that commit

These steps are necessary to realign the git history for these
repos which is a requirement for being able to commit upstream.

# repos

There are about 40 repos that need to be sorted

This section contains notes about each repo

1. account

  DONE
  jiocloud/puppet-account

3. apache -> ../module\_source/puppetlabs-apache-1.1.1

  DONE matches release 1.1.1
  forked as jiolcoud/puppetlabs/apache

4. apt -> ../module\_source/puppetlabs-apt-1.4.2

  DONE - version 1.4.2

6. ceph -> ../module\_source/puppet-ceph

  - DONE

7. cinder -> ../module\_source/puppet-cinder

  - DONE

8. concat -> ../module\_source/puppetlabs-concat-1.1.0-rc1

  DONE Matches ref: 162048133d1579a4c6d0268d8e0d29fecdbb73d9

9. contrail -> ../module\_source/contrail-puppet/contrail

  DONE - jiocloud/puppet-contrail exists

10. cron

  DONE - jiocloud/puppet-cron exists

  Harish: I searched to have complete cron management including service and crontab and user crons etc, and to have user cron restruction etc, but did not see one, so I just started this module, not completed and is not currently being used. I pushed it to jiocloud/puppet-cron and will continue developing it there.

11. glance -> ../module\_source/puppet-glance

   DONE

12. horizon -> ../module\_source/puppet-horizon

  DONE

13. inifile -> ../module\_source/puppetlabs-inifile

  DONE: matches upstream commit: ab21bd3

  Harish: this is forked from https://github.com/puppetlabs/puppetlabs-inifile

14. jiocloud

  TODO - will be pushed to jiocloud/puppet-jiocloud

15 jiocloud\_registration

  TODO - will be pushed to jiocloud/jiocloudregistration

16 keystone -> ../module\_source/puppet-keystone

  TODO - pushed to jiocloud/puppet-keystone
    there are some diffs that I could not resolve, need to manually check the diffs

17 kvm

  DONE - jiocloud/puppet-kvm exists

18 logrotate

  DONE - matches commit: d569bcee1b43fa1af816c21afb5664d8e5235553 from: rodjek/puppet-logrotate

19 lvm

  TODO - figure out lvm. It is a forked repo from puppetlabs with inline
  modifications. This is a great example of what not to do.

  Harish: Amar had created this module.

20 memcached -> ../module\_source/saz-memcached-2.2.4

  DONE matches commmit: fee24ce from upstream: saz/memcached


21 mysql -> ../module\_source/puppetlabs-mysql-2.2.3

  DONE - matches 2.2.3


  Harish: I had done some workaround to this module to work with mariadb package which are coming with ubuntu, But It seems we can keep it outside of this module - may be in jiocloud module. I will see it.


  Dan - I would prefer these be in a puppet-mariadb module

22 network -> ../module\_source/attachmentgenie-network-1.0.1


  TODO - Reconcile manually

  Harish: I will fix it.

23 neutron -> ../module\_source/puppet-neutron

  DONE

24 nova -> ../module\_source/puppet-nova

  DONE

25 nscd

  DONE - jiocloud/puppet-nscd

26 ntp -> ../module\_source/puppetlabs-ntp-3.0.1

  DONE - matches 3.0.1

27 openstack

  Harish: currenly we only using this to setup keystone, I can just change those code to directly use puppet-keystone.

29 rabbitmq -> ../module\_source/puppetlabs-rabbitmq-4.0.0

  DONE - matches 4.0.0

30 resolver

  DONE jiocloud/puppet-resolver

31 sethostname

  DONE - jiocloud/puppet-sethostname

  Harish: i created it to set hostname based on reverse dns lookup and optionally parse the dns name and create dns cnames for short server name ( basically the server name have some coded name using which one can derive the physical location - e.g compute node 1 has name JD0701b-cp1 - first part says the physical location of the server (datacenter, server room, row, rack and server number ) and second part says logical name of the node)

32 ssh -> ../module\_source/puppet-ssh

  TODO: this was forked, needs to be rebased, or we need to understand why we forked it
  this is a forked module with no jiocloud repo

33 staging -> ../module\_source/nanliu-staging-0.4.1

  DONE - matched version 0.4.1 from upstream

34 stdlib -> ../module\_source/puppetlabs-stdlib-4.1.0

  DONE - matched version 4.1.0 from upstream

35 sudo -> ../module\_source/puppet-sudo/

  DONE matches 62b93d from upstream

36 sysctl -> ../module\_source/puppet-sysctl

  DONE - matched 4a46338 from upstream

  Harish: Just a test module, somebody written. no need to migrate.

  Dan - I'm not so sure about that. Some openstack components require sysctl updates

38 timezone

  non-forked module with no repo
  Harish: forked from https://forge.puppetlabs.com/saz/timezone

39 zeromq

  non-forked module with no jiocloud repo
  Harish: It doesnt exist anymore. This code has been migrated to puppet-nova/zeromq
=======
  DONE - matched commit: v2.0.0 from upstream saz/puppet-timezone

39 zeromq

  DONE - jiocloud/puppet-zeromq exists

40zookeeper -> ../module\_source/viirya-zookeeper-0.0.7

  TODO : kind of matches
    commit: 5ce7acebbee871f3cd4e8c6ed2916440eb6a03e6

41 aptmirror
   non-forked module with jiocloud module (jiocloud/puppet-aptmirror)

# todo

there are several things that still need to be done for this project:

1. for repos where there is no upstream:

- convert the repos to svn repos
- create a repo jiocloud/puppet-<name>

2. for modules that are marked above as DONE.

  * double check jiocloud/puppet-<name>
  * go to the svn\_git\_port branch
  * make sure the commits look correct

3. for all other modules (both repos that we have changed as well as repos that we forked but did not
change)

- using the github fork button, fork the upstream module
- create the module jiocloud/jiocloud-<name> with the current svn repo


apply the reconcile tool to make sure we understand the state of our code compared to upstream

## Notes

a few of the modules were unlabeled modified forks with files removed, (logrotate, lvm)
please don't do this
