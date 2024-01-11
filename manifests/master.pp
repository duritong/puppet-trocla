# Class: trocla::master
#
# This module manages the necessary things for trocla on a master.
#
# @param package_name
# @param provider
# @param source
#
class trocla::master (
  String $package_name       = 'trocla',
  Optional[String] $provider = undef,
  Optional[String] $source   = undef,
) {
  package { 'trocla':
    ensure   => 'installed',
    name     => $package_name,
    provider => $provider,
    source   => $source,
  }

  if $provider != 'gem' and $provider != 'puppetserver_gem' and $facts['os']['family'] == 'RedHat' {
    Package['trocla'] {
      name => 'rubygem-trocla'
    }
  }
}
