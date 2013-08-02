#Installs configuration files for the trocla agent/CLI
#
#Options
# [*adapter*] Defines the adapter type to use for trocla agent. Generally YAML
# [*adapter_options*] This will contain a hash of the actual options to pass the
# trocla configuration. Generally you might pass the file option for key-file
# [*keysize*] Define the length of default passwords to create. 16 by default
class trocla::config (
  $adapter         = undef,
  $keysize         = 16,
  $adapter_options = { 'default' => '' },
) {
  require trocla::master

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
