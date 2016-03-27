require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'trocla::master::hiera', :type => 'class' do
  context 'with default params' do
    it { should compile.with_all_deps }
    it { should contain_package('rubygem-hiera-backend-trocla').with(
      :ensure => 'present'
    )}
  end
end

