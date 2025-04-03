# Class: trocla::master
#
# This module manages the necessary things for trocla on a master.
#
class trocla::master (
  $provider = 'default',
) {
  package {'trocla':
    ensure => 'installed',
  }

  if $provider != 'default' {
    Package['trocla']{
      provider => $provider,
    }
  }
  if $provider != 'gem' and $provider != 'puppetserver_gem' and $facts['os']['family'] == 'RedHat' {
    Package['trocla']{
      name => 'rubygem-trocla'
    }
  }
}
