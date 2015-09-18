# Class: trocla::master
#
# This module manages the necessary things for trocla on a master.
#
class trocla::master (
  $provider     = gem,
) {
  #Main trocla install
  package {'trocla':
    ensure   => present,
    provider => $provider,
  }

  if $provider != 'gem' {
    Package['trocla']{
      name => 'rubygem-trocla'
    }
  }
}
