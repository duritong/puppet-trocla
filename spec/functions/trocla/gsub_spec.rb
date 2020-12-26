require 'spec_helper'

describe 'trocla::gsub' do
  before do
    Puppet.settings[:config] = File.expand_path(File.join(__FILE__, '..', '..', '..', 'fixtures/puppet.conf'))
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
end
