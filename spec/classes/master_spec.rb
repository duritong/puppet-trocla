# frozen_string_literal: true

require 'spec_helper'

describe 'trocla::master', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default params' do
        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('trocla').with(
            ensure: 'installed',
          )
        }

        if facts[:os]['family'] == 'RedHat'
          it {
            is_expected.to contain_package('trocla').with(
              name: 'rubygem-trocla',
            )
          }
        end
      end

      context 'with gem provider' do
        let(:params) do
          {
            provider: 'gem',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('trocla').with(
            ensure: 'installed',
            provider: 'gem',
          )
        }

        if facts[:os]['family'] == 'RedHat'
          it {
            is_expected.to contain_package('trocla').with(
              name: 'trocla',
            )
          }
        end
      end
    end
  end
end
