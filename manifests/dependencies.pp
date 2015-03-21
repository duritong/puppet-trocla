# manage trocla's dependencies
#
# [*provider*] How to install the dependencies.
class trocla::dependencies(
  $provider = gem,
) {
  package { [ 'moneta', 'highline', 'bcrypt' ]:
    ensure   => present,
    provider => $provider,
  }
}
