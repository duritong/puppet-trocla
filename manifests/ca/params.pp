# input for a ca from trocla, so that you need only
#
# @param trocla_options
#
# trocla('some_ca','x509',$trocla::ca::params::ca_options)
class trocla::ca::params (
  Hash $trocla_options = {
    'profiles' => ['sysdomain_nc','x509veryverylong'],
    'CN'       => "automated-ca ${name} for ${facts['networking']['domain']}",
  },
) {
  $ca_options = merge($trocla_options, { become_ca => true, render => { certonly => true } })
}
