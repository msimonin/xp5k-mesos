class scenario::role::slave{
  class {'::scenario::profile::docker':} ->
  class {'::scenario::profile::slave':}
}

