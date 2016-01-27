require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'trocla::config', :type => 'class' do
  let(:facts){
    {
      :domain => 'example.com',
    }
  }
  context 'with default params' do
    it { should contain_class('trocla::params') }
    it { should contain_class('trocla::master') }
    it { should contain_file('/etc/puppet/troclarc.yaml').with(
      :owner => 'root',
      :group => 'puppet',
      :mode  => '0640'
    )}
    it { should contain_file('/etc/puppet/troclarc.yaml').with_content("---
profiles:
  sysdomain_nc:
    name_constraints:
    - example.com
") }
    it { should contain_file('/etc/troclarc.yaml').with(
      :ensure => 'link',
      :target => '/etc/puppet/troclarc.yaml'
    )}

    it { should compile.with_all_deps }
  end

  context 'with other params' do
    let(:params) {
      {
        :options => {
          'length'   => 24,
          'profiles' => 'mydefaultprofile',
          'random'   => false,
          'expires'  => 60*60*24, #1day
        },
        :profiles => {
          'mydefaultprofile' => {
            'length' => 20,
          },
          'anotherprofile' => {
            'random' => true,
            'expires' => false,
          },
        },
        :x509_profile_domain_constraints => ['domain1.com','domain2.com'],
        :store => 'moneta',
        :store_options => {
          'adapter' => 'Sequel',
          'adapter_options' => {
            'db'       => 'mysql://db.server.name',
            'user'     => 'trocla',
            'password' => 'secret_password',
            'database' => 'trocladb',
            'table'    => 'trocla',
          },
        },
        :encryption => 'ssl',
        :encryption_options => {
          'private_key' => '/var/lib/puppet/ssl/private_keys/trocla.pem',
          'public_key'  => '/var/lib/puppet/ssl/public_keys/trocla.pem',
        },
        :manage_dependencies => false,
      }
    }
    it { should contain_class('trocla::params') }
    it { should_not contain_class('trocla::master') }
    it { should contain_file('/etc/puppet/troclarc.yaml').with(
      :owner => 'root',
      :group => 'puppet',
      :mode  => '0640'
    )}
    it { should contain_file('/etc/puppet/troclarc.yaml').with_content("---
encryption: :ssl
encryption_options:
  :private_key: /var/lib/puppet/ssl/private_keys/trocla.pem
  :public_key: /var/lib/puppet/ssl/public_keys/trocla.pem
options:
  expires: 86400
  length: 24
  profiles: mydefaultprofile
  random: false
profiles:
  anotherprofile:
    expires: false
    random: true
  mydefaultprofile:
    length: 20
  sysdomain_nc:
    name_constraints:
    - domain1.com
    - domain2.com
store: :moneta
store_options:
  adapter: :Sequel
  adapter_options:
    :database: trocladb
    :db: mysql://db.server.name
    :password: secret_password
    :table: trocla
    :user: trocla
") }
    it { should contain_file('/etc/troclarc.yaml').with(
      :ensure => 'link',
      :target => '/etc/puppet/troclarc.yaml'
    )}

    it { should compile.with_all_deps }
  end
end

