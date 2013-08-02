# Class: trocla::master
#
# This module manages the necessary things for trocla on a master.
#
# [Remember: No empty lines between comments and class definition]
class trocla::master (
  $install_deps = false,
  $use_rubygems = true,
) {

  #Select if the upstream rubygems modules should be required for install
  if $use_rubygems {
    require rubygems::moneta
    require rubygems::highline
  }

  #Manually install requirements via gem
  if $install_deps {
    package { 'moneta':
      ensure   => present,
      provider => gem,
    }
    package { 'highline':
      ensure   => present,
      provider => gem,
    }
  }

  #Main trocla install
  package {'trocla':
    ensure   => present,
    provider => gem,
  }

}
