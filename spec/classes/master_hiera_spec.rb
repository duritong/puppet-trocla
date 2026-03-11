# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe 'trocla::master::hiera', type: 'class' do
  context 'with default params' do
    it { is_expected.to compile.with_all_deps }

    it {
      is_expected.to contain_package('rubygem-hiera-backend-trocla').with(
        ensure: 'present',
      )
    }
  end
end
