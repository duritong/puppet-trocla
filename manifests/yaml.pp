# A class for an eady start with trocla.
# This will install and configure trocla with the
# default yaml storage.
#
# [*password_length*]  The default length of new passwords: 16
# [*random_passwords*] Whether trocla should generate random
#                      passwords or not. Default: true
# [*data_file*]        Where to store the passwords.
#                      Default: {$settings::server_datadir}/trocla_data.yaml"
#                      This will likely be: /var/lib/puppet/server_data/trocla_data.yaml
class trocla::yaml(
  $password_length  = 16,
  $random_passwords = true,
  $data_file        = "${settings::server_datadir}/trocla_data.yaml",
) {

  class{'trocla::config':
    password_length   => $password_length,
    random_passwords  => $random_passwords,
    adapter           => 'YAML',
    adapter_options   => {
      file => $data_file,
    },
  }

  file{$data_file:
    ensure  => file,
    owner   => puppet,
    group   => 0,
    mode    => '0600';
  }
}
