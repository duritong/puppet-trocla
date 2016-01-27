# input for a ca from trocla, so that you need only
#
# trocla('some_ca','x509',$trocla::ca::params::ca_options)
class trocla::ca::params(
  $trocla_options = {
    'profiles' => ['sysdomain_nc','x509long'],
    'CN'       => "automated-ca ${name} for ${::domain}",
  },
) {
  $ca_options = merge($trocla_options,{ become_ca => true, render => { certonly => true }})
}
