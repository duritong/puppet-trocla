# A class for an eady start with trocla.
# This will install and configure trocla with the
# default yaml storage.
#
# @param manage_data_dir
# @param data_file
#   Where to store the passwords. Default: /var/lib/trocla/trocla_data.yaml. This should be managed using the package.
# @param edit_uid
#                      
class trocla::yaml (
  Boolean $manage_data_dir = true,
  String $data_file        = '/var/lib/trocla/trocla_data.yaml',
  String $edit_uid         = 'puppet',
) {
  class { 'trocla::config':
    edit_uid      => $edit_uid,
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
    file { $data_dir:
      ensure  => directory,
      owner   => $edit_uid,
      group   => 0,
      mode    => '0600',
      require => Package['trocla'];
    }
  }
  file {
    $data_file:
      ensure  => file,
      owner   => $edit_uid,
      group   => 0,
      mode    => '0600',
      require => Package['trocla'];
  }
}
