# manage trocla/hiera integration
class trocla::master::hiera(
  $provider = 'default',
){
  package{'hiera-backend-trocla':
    ensure => present,
  }

  if $provider != 'default' {
    Package['hiera-backend-trocla']{
      provider => $provider,
    }
  }
  if $provider != 'gem' and $::osfamily == 'RedHat' {
    Package['hiera-backend-trocla']{
      name => 'rubygem-hiera-backend-trocla'
    }
  }

}
