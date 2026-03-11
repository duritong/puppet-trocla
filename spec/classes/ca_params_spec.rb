# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe 'trocla::ca::params', type: 'class' do
  context 'with default params' do
    it { is_expected.to compile.with_all_deps }
  end
end
