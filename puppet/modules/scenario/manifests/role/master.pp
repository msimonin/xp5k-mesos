class scenario::role::master {
  class { '::scenario::profile::master':} ->
  class { '::scenario::profile::marathon':} 
}

