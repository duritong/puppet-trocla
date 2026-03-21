# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'tmpdir'

describe 'trocla_set' do
  # rubocop:disable RSpec/InstanceVariable
  # rubocop:disable RSpec/BeforeAfterAll
  before(:context) do
    @config_dir = Dir.mktmpdir

    troclarc = File.join(@config_dir, 'troclarc.yaml')
    @storage = File.join(@config_dir, 'trocla_storage.yaml')
    File.write(troclarc, <<~CONFIG
      ---
      store: :moneta
      store_options:
        adapter: :YAML
        adapter_options:
          :file: '#{@storage}'
    CONFIG
    )
  end

  after(:context) do
    FileUtils.remove_entry(@config_dir)
  end
  # rubocop:enable RSpec/BeforeAfterAll

  before do
    # puppet settings seem to be reset automatically at the end of one context
    # so we need to set this before every example to make sure it stays
    # available
    Puppet.settings[:config] = File.join(@config_dir, 'puppet.conf')

    # We want to reinitialize the storage for every test in order to avoid
    # side-effects from one test to change the results of another.
    File.write(@storage, <<~STORAGE
      ---
      test:
        plain: XXX
      bar:
        plain: AAA
        mysql: "*5AF9D0EA5F6406FB0EDD0507F81C1D5CEBE8AC9C"
    STORAGE
    )
  end

  after do
    FileUtils.remove_entry(@storage)
  end

  context 'with plaintext absent and different return format then the one set' do
    it 'raises an exception' do
      is_expected.to run.with_params('unknown', 'new_value', 'mysql', 'sha512crypt').and_raise_error(Puppet::ParseError, %r{Plaintext password is not present})
    end
  end

  context 'with default format' do
    it 'sets password' do
      is_expected.to run.with_params('test', 'AAA').and_return('AAA')
    end
  end

  context 'with mysql format' do
    it 'sets password' do
      is_expected.to run.with_params('bar', '*F069F1F342C2D6B46AC36DFA58FFC8B48C9E06A7', 'mysql').and_return('*F069F1F342C2D6B46AC36DFA58FFC8B48C9E06A7')
    end
  end

  context 'with plain format but return format is sha512crypt' do
    it 'sets password' do
      is_expected.to run.with_params('test', 'verysecret', 'plain', 'sha512crypt').and_return(%r{^\$6\$})
    end
  end

  context 'with plain format but return format is pgsql with options' do
    it 'sets password' do
      is_expected.to run.with_params('test', 'verysecret', 'plain', 'pgsql', { 'username' => 'user4' }).and_return(%r{^SCRAM-SHA-256\$})
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
