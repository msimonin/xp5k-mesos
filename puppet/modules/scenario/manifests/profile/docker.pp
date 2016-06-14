class scenario::profile::docker {

  $pre = ['apt-transport-https', 'ca-certificates']
  package {$pre: 
    ensure => installed
  }

  exec {'docker-key':
    command => "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D",
    path    => ['/bin', '/usr/bin']
  }
  
  $url = '/etc/apt/sources.list.d/docker.list'
  file {$url: 
    content => "deb https://apt.dockerproject.org/repo ubuntu-trusty main"
  }

  exec {'update-docker':
    command => "apt-get -y update",
    path    => ['/bin', '/usr/bin']
  }

  package {'docker-engine':
    ensure => installed
  }

  Exec['docker-key'] ->
  File[$url] ->
  Package[$pre] ->
  Exec['update-docker'] -> 
  Package['docker-engine']
}
