#Installs configuration files for the trocla agent/CLI
#
#Options
# [*options*]             Options for trocla. Default: empty hash.
# [*profiles*]            Profiles for trocla. Default: empty hash.
# [*x509_profile_domain_constraints*]
#                         A profile for x509 name constraint that matches
#                         the own domain by default.
#                         This will add a profile for x509 certs with the
#                         option 'name_constraints' set to this array of
#                         domains.
# [*store*]               Defines the store to be used for trocla. By default
#                         it's not set, meaning trocla's default (moneta) will
#                         be used.
# [*store_options*]       This will contain a hash of the options to pass the
#                         trocla store configuration.
# [*encryption*]          Defines the encryption method for password stored in
#                         the backend. By default it's not set, meaning trocla's
#                         default (none) will be used.
# [*encryption_options*]  This will contain a hash of the options for the
#                         encryption. Default: empty Hash
# [*manage_dependencies*] Whether to manage the dependencies or not.
#                         Default *true*
# [*edit_uid*] edit_uid
#                         Default: puppet
#
class trocla::config (
  Hash $options                          = {},
  Hash $profiles                         = {},
  Array $x509_profile_domain_constraints = [$facts['networking']['domain']],
  Optional[String] $store                = undef,
  Hash $store_options                    = {},
  Optional[String] $encryption           = undef,
  Hash $encryption_options               = {},
  Boolean $manage_dependencies           = true,
  String $edit_uid                       = 'puppet',
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
    $merged_profiles = merge($default_profiles,$profiles)
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
