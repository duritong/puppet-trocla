# @summary Default values for generating an 509 CA
#
# @param trocla_options
#   Default trola options for a CA. This gets merged with defaut options that
#   indicate the certificate should be a CA. You can pass
#   `$trocla::ca::params::ca_options` as the third parameter to `trocla()` in
#   order to get an x509 CA.
#
# @example Generating an 509 CA
#   trocla('some_ca', 'x509', $trocla::ca::params::ca_options)
#
class trocla::ca::params (
  Hash $trocla_options = {
    'profiles' => ['sysdomain_nc','x509veryverylong'],
    'CN'       => "automated-ca ${name} for ${facts['networking']['domain']}",
  },
) {
  $ca_options = merge($trocla_options, { become_ca => true, render => { certonly => true } })
}
