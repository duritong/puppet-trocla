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
