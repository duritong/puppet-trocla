# @summary Installs configuration files for the trocla agent/CLI
#
# @param options
#   Options for trocla. Default: empty hash.
# @param profiles
#   Profiles for trocla. Default: empty hash.
# @param x509_profile_domain_constraints
#   A profile for x509 name constraint that matches the own domain by default.
#   This will add a profile for x509 certs with the option 'name_constraints'
#   set to this array of domains.
# @param store
#   Defines the store to be used for trocla. By default it's not set, meaning
#   trocla's default (moneta) will be used.
# @param store_options
#   This will contain a hash of the options to pass the trocla store
#   configuration.
# @param encryption
#   Defines the encryption method for password stored in the backend. By default
#   it's not set, meaning trocla's default (none) will be used.
# @param encryption_options
#   This will contain a hash of the options for the encryption. Default: empty
#   Hash
# @param manage_dependencies
#   Whether to manage the dependencies or not. Default *true*
# @param edit_uid
#   Name of the group assigned to the troclarc file.
#
class trocla::config (
  Hash $options = {},
  Hash $profiles = {},
  Array[String] $x509_profile_domain_constraints = [$facts['networking']['domain']],
  Optional[String] $store = undef,
  Hash $store_options = {},
  Optional[Variant[String, Array[String]]] $encryption = undef,
  Hash $encryption_options = {},
  Boolean $manage_dependencies = true,
  String $edit_uid = 'puppet',
) {
  include trocla::params
  if $manage_dependencies {
    require trocla::master
  }

  if empty($x509_profile_domain_constraints) {
    $merged_profiles = $profiles
  } else {
    $default_profiles = {
      "${trocla::params::sysdomain_profile_name}" => {
        name_constraints => $x509_profile_domain_constraints,
      },
    }
    $merged_profiles = stdlib::merge($default_profiles,$profiles)
  }

  # Deploy default config file and link it for trocla cli lookup
  file {
    "${settings::confdir}/troclarc.yaml":
      content => template('trocla/troclarc.yaml.erb'),
      owner   => 'root',
      group   => $edit_uid,
      mode    => '0640';
    '/etc/troclarc.yaml':
      ensure => link,
      target => "${settings::confdir}/troclarc.yaml";
  }
}
