# A class for an eady start with trocla.
# This will install and configure trocla with the
# default yaml storage.
#
# [*data_file*]        Where to store the passwords.
#                      Default: /var/lib/trocla/trocla_data.yaml
#                      This should be managed using the package.
class trocla::yaml(
  $manage_data_dir = true,
  $data_file       = '/var/lib/trocla/trocla_data.yaml',
) {

  class{'trocla::config':
    store         => 'moneta',
    store_options => {
      adapter         => 'YAML',
      adapter_options => {
        file => $data_file,
      },
    },
  }

  if $manage_data_dir {
    $data_dir = dirname($data_file)
    file{$data_dir:
      ensure  => directory,
      owner   => puppet,
      group   => 0,
      mode    => '0600',
      require => Package['trocla'];
    }
  }
  file{
    $data_file:
      ensure  => file,
      owner   => puppet,
      group   => 0,
      mode    => '0600',
      require => Package['trocla'];
  }
}
