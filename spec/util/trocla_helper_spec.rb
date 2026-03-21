# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'tmpdir'
require 'puppet/util/trocla_helper'

describe 'Puppet::Util::TroclaHelper::trocla' do
  # The goal of this test file is not to test all of the possible behavior of
  # trocla but rather to make sure that it behaves as we expect it to when
  # called in the manner that the helper function is called throughout the
  # puppet module functions.
  #
  # This test file is extremely fickle: the singleton Trocla class stored by
  # TroclaHelper reads the troclarc.yaml configuration file only once for all
  # tests.
  # Since we're creating a new tmpdir in the before(:context) hook, if we have
  # more than one context, we'll end up creating new config and storage files
  # but the singleton class will not follow this change. So we need to stick to
  # using only one context for all tests.
  # Also, if one test somehow raises an error, i causes all tests after itself
  # to fail.
  context 'with basic trocla configuration' do
    # rubocop:disable RSpec/InstanceVariable
    # rubocop:disable RSpec/BeforeAfterAll
    before(:context) do
      @config_dir = Dir.mktmpdir
      Puppet.settings[:config] = File.join(@config_dir, 'puppet.conf')

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

    # :password
    #
    it ':password returns known key with default format' do
      # The `trocla()` puppet function always passes in all params to the helper
      # function.
      expect(Puppet::Util::TroclaHelper.trocla(:password, true, 'test', 'plain', {})).to eq('XXX')
    end

    it ':password returns known key with format mysql' do
      expect(Puppet::Util::TroclaHelper.trocla(:password, true, 'bar', 'mysql', {})).to eq('*5AF9D0EA5F6406FB0EDD0507F81C1D5CEBE8AC9C')
    end

    it ':password returns new value for unknown key with options' do
      # The value will be random. We only care that trocla respected the
      # length option
      expect(Puppet::Util::TroclaHelper.trocla(:password, true, 'long', 'plain', { 'length' => '5' })).to match(%r{^.{5}$})
      # This example is mostly present to ensure that we can pass values of
      # other types than String to options.
      expect(Puppet::Util::TroclaHelper.trocla(:password, true, 'new', 'sshkey', { 'bits' => 4096 })).to match(%r{^-----BEGIN RSA PRIVATE KEY-----.*})
    end

    # :get_password
    #
    it ':get_password returns known key with default format' do
      expect(Puppet::Util::TroclaHelper.trocla(:get_password, false, 'test', 'plain', {})).to eq('XXX')
    end

    it ':get_password returns known key with format mysql' do
      expect(Puppet::Util::TroclaHelper.trocla(:get_password, false, 'bar', 'mysql', {})).to eq('*5AF9D0EA5F6406FB0EDD0507F81C1D5CEBE8AC9C')
    end

    it ':get_password returns known key with format x509 and format options' do
      private_key = <<~PRIVATE_KEY
        -----BEGIN RSA PRIVATE KEY-----
        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
        -----END RSA PRIVATE KEY-----
      PRIVATE_KEY

      File.write(@storage, <<~STORAGE
        ---
        x509_cert:
          x509: |
        #{private_key.gsub(%r{^}, '    ')}
      STORAGE
      )

      expect(Puppet::Util::TroclaHelper.trocla(:get_password, true, 'x509_cert', 'x509', 'render: keyonly')).to eq(private_key)
    end

    it ':get_password returns nil on unknown key' do
      expect(Puppet::Util::TroclaHelper.trocla(:get_password, false, 'non-existent', 'plain', {})).to be_nil
      # Nothing gets added to the storage file
      expect(File.read(@storage)).to eq(<<~STORAGE,
        ---
        test:
          plain: XXX
        bar:
          plain: AAA
          mysql: "*5AF9D0EA5F6406FB0EDD0507F81C1D5CEBE8AC9C"
      STORAGE
                                       )
    end

    # Argument santiy
    #
    # This needs to be placed after all tests. Since the exception is raised
    # before @store is initialized, we end up breaking up all tests if this is
    # the first thing that gets called
    #
    it 'calling any function with no storage key raises an error' do
      expect { Puppet::Util::TroclaHelper.trocla(:anything, false) }.to raise_error(Puppet::ParseError, %r{at least a key})
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
