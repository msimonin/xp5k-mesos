class scenario::profile::slave inherits scenario::profile {

  # configure master

  #
  # Zookeeper
  #
  $zhosts = hiera("mesos::masters")

  package { 'zookeeperd':
    ensure => absent
  }
  
  service { 'mesos-slave':
    ensure  => running,
    require => [Package['mesos'], File['/etc/mesos/zk']]
  }
  
  file { '/etc/mesos-slave/containerizers':
    content => 'docker,mesos',
    require => Package['mesos'],
    notify  => Service['mesos-slave']
  }

  service { 'mesos-master':
    ensure  => stopped,
  }


}
