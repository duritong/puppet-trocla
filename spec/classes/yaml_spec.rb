require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'trocla::yaml', :type => 'class' do
  let(:facts){
    {
      :osfamily => 'CentOS',
      :domain => 'example.com',
    }
  }
  context 'with default params' do
    it { should contain_class('trocla::config').with(
      'store' => 'moneta',
      'store_options' => {
        'adapter' => 'YAML',
        'adapter_options' => {
          'file' => '/var/lib/trocla/trocla_data.yaml',
        }
      }
    )}
    it { should contain_file('/etc/puppet/troclarc.yaml').with_content("---
profiles:
  sysdomain_nc:
    name_constraints:
    - example.com
store: :moneta
store_options:
  adapter: :YAML
  adapter_options:
    :file: /var/lib/trocla/trocla_data.yaml
") }
    it { should contain_file('/var/lib/trocla').with(
      :ensure  => 'directory',
      :owner   => 'puppet',
      :group   => 0,
      :mode    => '0600',
      :require => 'Package[trocla]'
    )}
    it { should contain_file('/var/lib/trocla/trocla_data.yaml').with(
      :ensure  => 'file',
      :owner   => 'puppet',
      :group   => 0,
      :mode    => '0600',
      :require => 'Package[trocla]'
    )}
    it { should compile.with_all_deps }
  end
end

