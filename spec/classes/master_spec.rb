require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'trocla::master', :type => 'class' do
  context 'with default params' do
    context 'on RedHat' do
      let(:facts) {
        {
          :osfamily => 'RedHat',
        }
      }
      it { should contain_package('trocla').with(
        :name     => 'rubygem-trocla',
        :ensure   => 'installed'
      )}
      it { should compile.with_all_deps }
    end
    context 'on Debian' do
      let(:facts) {
        {
          :osfamily => 'Debian',
        }
      }
      it { should contain_package('trocla').with(
        :ensure   => 'installed'
      )}
      it { should compile.with_all_deps }
    end
  end
  context 'with gem provider' do
    let(:params){
      {
        :provider => 'gem'
      }
    }
    it { should contain_package('trocla').with(
      :ensure   => 'installed',
      :provider => 'gem'
    )}

    it { should compile.with_all_deps }
    context 'on RedHat' do
      it { should contain_package('trocla').with(
        :name     => 'trocla',
        :ensure   => 'installed',
        :provider => 'gem'
      )}

      it { should compile.with_all_deps }
    end
  end
end

