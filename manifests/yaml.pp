# @summary A class for an easy start with trocla.
#
# This will install and configure trocla with the
# default yaml storage.
#
# @param manage_data_dir
#   By default the puppet module will create and set permissions on the
#   directory where the storage file is placed. Set this to false to avoid
#   managing the directory.
# @param data_file
#   Absolute path to where to store the passwords. This should be managed using
#   the package. Default: /var/lib/trocla/trocla_data.yaml
# @param edit_uid
#   Name of the system group assigned to the storage file
#
class trocla::yaml (
  Boolean $manage_data_dir = true,
  Stdlib::Absolutepath $data_file = '/var/lib/trocla/trocla_data.yaml',
  String $edit_uid = 'puppet',
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
    Package<| title == 'trocla' |> -> file {
      $data_dir:
        ensure => directory,
        owner  => $edit_uid,
        group  => 0,
        mode   => '0600';
    }
  }
  Package<| title == 'trocla' |> -> file {
    $data_file:
      ensure => file,
      owner  => $edit_uid,
      group  => 0,
      mode   => '0600';
  }
}
