# manage trocla's dependencies
#
# [*provider*] How to install the dependencies.
class trocla::dependencies(
  $provider = gem,
) {
  package { 'moneta':
    ensure   => present,
    provider => $provider,
  }
  package { 'highline':
    ensure   => present,
    provider => $provider,
  }
}
