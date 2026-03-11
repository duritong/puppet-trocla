# @summary Manage the necessary things for trocla on a master.
#
# @param provider
#   Name of the package provider used for installing the trocla package. The
#   default value ('default') uses the distro's package manager.
#
class trocla::master (
  String $provider = 'default',
) {
  package { 'trocla':
    ensure => 'installed',
  }

  if $provider != 'default' {
    Package['trocla'] {
      provider => $provider,
    }
  }
  if $provider != 'gem' and $provider != 'puppetserver_gem' and $facts['os']['family'] == 'RedHat' {
    Package['trocla'] {
      name => 'rubygem-trocla'
    }
  }
}
