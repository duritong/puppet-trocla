# Class: trocla::master
#
# This module manages the necessary things for trocla on a master.
#
# [*install_deps*]: Whether to directly install the necessary dependencies
# [*use_rubygems*]: Use the rubygems module to manage your dependencies
# [*provider*]:     Which provider to use to install your dependencies, if you
#                   don't use the rubygems module
class trocla::master (
  $install_deps = false,
  $use_rubygems = true,
  $provider     = gem,
) {

  #Select if the upstream rubygems modules should be required for install
  if $use_rubygems {
    require rubygems::moneta
    require rubygems::highline
  }

  #Manually install requirements via gem
  if $install_deps {
    class{'trocla::dependencies':
      provider => $provider,
    }
  }

  #Main trocla install
  package {'trocla':
    ensure   => present,
    provider => $provider,
  }

}
