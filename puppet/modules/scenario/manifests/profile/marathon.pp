class scenario::profile::marathon {
  
  # install mesos key
  exec {'oracle-java-8-key':
    command => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7B2C3B0889BF5709A105D03AC2518248EEA14886",
    path    => ['/bin', '/usr/bin']
  }
  
  $url = $::lsbdistid ? {
    'Ubuntu' => "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main "
  }

  file {'/etc/apt/sources.list.d/oracle-java-8.list':
    content => "$url"
  }

  exec {'update-marathon':
    command => "apt-get -y update",
    path    => ['/bin', '/usr/bin']
  }
  
  exec {'accept-license':
    command => "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections",
    path    => ['/bin', '/usr/bin']
  }

  package {'oracle-java8-installer':
    ensure => installed
  }

  package {'oracle-java8-set-default':
    ensure => installed
  }

  package {'marathon':
    ensure => installed
  }

  service {'marathon': 
    ensure => running
  }

  Exec['oracle-java-8-key'] -> 
  File['/etc/apt/sources.list.d/oracle-java-8.list']
  Exec['update-marathon'] -> 
  Exec['accept-license'] -> 
  Package['oracle-java8-installer'] ->
  Package['oracle-java8-set-default'] ->
  Package['marathon'] ->
  Service['marathon']

}
