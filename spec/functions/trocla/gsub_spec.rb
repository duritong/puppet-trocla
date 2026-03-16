# frozen_string_literal: true

require 'spec_helper'

describe 'trocla::gsub' do
  # Override the trocla function since that's not what we're testing here
  let(:pre_condition) do
    'function trocla(String $key, String $format) >> String {
      case $key {
        "test": { return "XXX" }
        "bar": { return "AAA" }
        "test-test": { return "===" }
        "bar-test": { return "BBB" }
        default: { fail("unexpected key ${key}") }
      }
    }'
  end

  it { is_expected.to run.with_params('foo').and_return 'foo' }

  context 'with data' do
    it { is_expected.to run.with_params('foo: %%TROCLA_test%%-bla').and_return 'foo: XXX-bla' }
    it { is_expected.to run.with_params('foo: %%TROCLA_test%%-%%TROCLA_test%%-bla').and_return 'foo: XXX-XXX-bla' }
    it { is_expected.to run.with_params('foo: %%TROCLA_test%%-%%TROCLA_bar%%-bla').and_return 'foo: XXX-AAA-bla' }
    it { is_expected.to run.with_params("foo: %%TROCLA_test%%\nbar: %%TROCLA_bar%%").and_return "foo: XXX\nbar: AAA" }
  end

  context 'with prefix' do
    it { is_expected.to run.with_params('foo: %%TROCLA_test%%-bla', 'prefix' => 'test-').and_return 'foo: ===-bla' }
  end

  context 'with key_to_prefix' do
    it { is_expected.to run.with_params("foo: %%TROCLA_test%%-bla\nbar: %%TROCLA_bar%%", 'key_to_prefix' => { 'test' => 'bar-' }).and_return "foo: BBB-bla\nbar: AAA" }
  end
end
