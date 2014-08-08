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

  This does not have a repo. Are we afraid of publishing the ssh pub keys?
  I created jiocloud/puppet-acccount, but did not populate any data into it.

2. add\_user\_to\_group

 I created jiocloud/puppet-add\_user\_to\_group, but did not put any data into it

3. apache -> ../module\_source/puppetlabs-apache-1.1.1

  forked module with no repo

4. apt -> ../module\_source/puppetlabs-apt-1.4.2

  forked module with no repo

5. base\_packages

  no repo

6. ceph -> ../module\_source/puppet-ceph

  - DONE

7. cinder -> ../module\_source/puppet-cinder

  - DONE

8. concat -> ../module\_source/puppetlabs-concat-1.1.0-rc1

  forked module with no jiocloud repo

9. contrail -> ../module\_source/contrail-puppet/contrail

  no repo

10. cron

  no repo

11. glance -> ../module\_source/puppet-glance

   DONE

12. horizon -> ../module\_source/puppet-horizon

  DONE

13. inifile -> ../module\_source/puppetlabs-inifile

  no repo

14. jiocloud

  no repo

15 ji ocloud\_registration

  no repo

16 keystone -> ../module\_source/puppet-keystone

  There were not common commits to based off of. We need to review the output and chat

17 kvm

  are we sure this doesn't have an upstream?

18 logrotate

  non-forked module with no jiocloud repo

19 lvm

  is this not a forked module?

20 memcached -> ../module\_source/saz-memcached-2.2.4

  forked module with no jiocloud repo

21 mysql -> ../module\_source/puppetlabs-mysql-2.2.3

  forked module with no jiocloud repo

22 network -> ../module\_source/attachmentgenie-network-1.0.1

  There is a repo (with two commits)

  I could nto reconcole how this is based on the upstream repo. This needs to be done
  manually.

23 neutron -> ../module\_source/puppet-neutron

  DONE

24 nova -> ../module\_source/puppet-nova

  DONE

25 nscd

  no repo (looks like a non-forked repo)

26 ntp -> ../module\_source/puppetlabs-ntp-3.0.1

  forked module with no jiocloud repo

27 openstack

  This is a special case b/c it's upstream has been deprecated. We should
  consider it a fork and try to stop using it ASAP.

28 python-django-horizon

this isn't even a valid module or class name. Cannot have dashes in the names.

29 rabbitmq -> ../module\_source/puppetlabs-rabbitmq-4.0.0

  forked module with no jiocloud repo

30 resolver

  non-forked module with jiocloud module

31 sethostname

  non-forked module with jiocloud module

32 ssh -> ../module\_source/puppet-ssh

  this is a forked module with no jiocloud repo

33 staging -> ../module\_source/nanliu-staging-0.4.1

  forked module with no jiocloud repo

34 stdlib -> ../module\_source/puppetlabs-stdlib-4.1.0

  forked module with no jiocloud repo

35 sudo -> ../module\_source/puppet-sudo/

  forked module with no jiocloud repo

36 sysctl -> ../module\_source/puppet-sysctl

  forked module with no jiocloud repo

37 tfile

  non-forked module with no repo

38 timezone

  non-forked module with no repo

39 zeromq

  non-forked module with no jiocloud repo

40zookeeper -> ../module\_source/viirya-zookeeper-0.0.7

  forked module with no jiocloud repo

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
