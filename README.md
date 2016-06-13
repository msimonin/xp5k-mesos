# Introduction

This is a scenario for https://github.com/grid5000/xp5k-openstack that deploys
Mesos instead of an Openstack distribution.
Since ```xp5k-openstack``` installs a puppet cluster and delegates the installation
of Openstack to the rake task ```scenario:main``` we just use this task to install
Mesos.

In conclusion it proves that ```xp5k-openstack``` can be used as a standard way
of deploying Puppetize environments in Grid'5000.


# scenario : Mesos

Deploy a Mesos/HDFS cluster on Grid'5000.

Inspired by http://mesosphere.com/docs/getting-started/datacenter/install/

Keywords : Grid'5000, puppet, capistrano, hiera, xp5k

## Optionnal ```xp.conf``` parameters

The following parameters are optionnal in the ```xp.conf``` file. If some are not set,
default values will bet set for them (see ```tasks/scenario.rb```). Here is an example :

```
masters: 1 # number of mesos-master instances to run each will run on a dedicated node
slaves: 3  # number of mesos-slave instances to run each will run on a dedicated node
```
