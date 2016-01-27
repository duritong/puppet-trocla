# manage trocla/hiera integration
class trocla::master::hiera {
  package{'rubygem-hiera-backend-trocla':
    ensure => present,
  }
}
