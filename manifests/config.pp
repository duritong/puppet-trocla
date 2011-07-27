class trocla::config {
  file{"${settings::confdir}/trocla.yaml":
    source => [ "puppet:///modules/site-trocla/${fqdn}/trocla.yaml",
                'puppet:///modules/site-trocla/trocla.yaml' ],
    require => Package['trocla'],
    owner => root, group => puppet, mode => 0640;           
  }
}
