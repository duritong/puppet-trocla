# frozen_string_literal: true

require 'spec_helper'

describe 'trocla::master::hiera', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default params' do
        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_package('rubygem-hiera-backend-trocla').with(
            ensure: 'present',
          )
        }
      end
    end
  end
end
