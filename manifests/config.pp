#Installs configuration files for the trocla agent/CLI
#
#Options
# [*adapter*]            Defines the adapter type to use for trocla agent.
#                        By default it's YAML
# [*adapter_options*]    This will contain a hash of the adapter options to pass the
#                        trocla configuration.
# [*encryption*]         Defines the encryption method for password stored in the backend.
#                        By default no encryption is used.
# [*ssl_options*]        This will contain a hash of the ssl options to pass the
#                        trocla configuration.
# [*password_length*]    Define the length of default passwords to create. 16 by default
# [*random_passwords*]   Should trocla generate random passwords
#                        if none can be found. *true* by default.
# [*manage_dependencies*] Whether to manage the dependencies or not. Default *true*
class trocla::config (
  $adapter            = 'YAML',
  $password_length      = 16,
  $random_passwords     = true,
  $adapter_options      = {},
  $encryption           = undef,
  $ssl_options          = {},
  $manage_dependencies  = true,
) {
  if $manage_dependencies {
    require trocla::master
  }

  # Deploy default config file and link it for trocla cli lookup
  file{
    "${settings::confdir}/troclarc.yaml":
      ensure  => present,
      content => template('trocla/troclarc.yaml.erb'),
      owner   => root,
      group   => puppet,
      mode    => '0640';
    '/etc/troclarc.yaml':
      ensure => link,
      target => "${settings::confdir}/troclarc.yaml";
  }

}
