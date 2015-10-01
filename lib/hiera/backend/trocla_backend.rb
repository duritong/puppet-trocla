# Custom hiera backend for trocla
#
# Only reacts to key namespace trocla::password::<trocla_key>. Looks up
# additional parameters via hiera itself as
# trocla::options::<trocla_key>::format (string) and
# trocla::options::<trocla_key>::options (hash). Looks for <trocla_key> in
# trocla as hiera/<source>/<trocla> with <source> iterating over the configured
# hiera hierarchy. If not found, creates and returns a new password with trocla
# key <trocla_key>.
#
# example entry in hiera.yaml:
# backends:
#   - ...
#   - trocla
# trocla:
#   - configfile: /etc/puppet/troclarc.yaml
#   - format: plain
#   - options:
#     length: 16
#
# example usage in hiera yaml file:
# kerberos::kdc_database_password: "%{hiera('trocla::password::kdc_database_password')}"
# trocla::options::kdc_database_password::format: 'plain'
# trocla::options::kdc_database_password::options:
#   length: 71
class Hiera
  module Backend
    class Trocla_backend

      def initialize
        @trocla = nil

        Hiera.debug("Hiera Trocla backend starting")
        require 'trocla'

        default_configfile = "/etc/puppet/troclarc.yaml"
        default_default_format = "plain"
        default_default_options = {}

        begin
          configfile = Config[:trocla][:configfile] || default_configfile
        rescue
          configfile = default_configfile
        end

        if not File.exist?(configfile)
          Hiera.warn("Trocla config file #{configfile} is not readable")
          return
        end

        begin
          @default_format = Config[:trocla][:format] || default_default_format
        rescue
          @default_format = default_default_format
        end

        begin
          @default_options = Config[:trocla][:options] || default_default_options
        rescue
          @default_options = default_default_options
        end

        @trocla = Trocla.new(configfile)
      end

      def lookup(key, scope, order_override, resolution_type)
        return nil unless @trocla

        Hiera.debug("Looking up #{key} in trocla backend")

        password_namespace = 'trocla::password::'
        options_namespace = 'trocla::options::'

        # we only accept trocla::password:: lookups because we do hiera lookups
        # ourselves and could otherwise cause loops
        return nil unless key.start_with?(password_namespace)

        # cut off trocla hiera namespace: trocla::password::root -> root
        trocla_key = key[password_namespace.length,
                         key.length - password_namespace.length]
        Hiera.debug("Looking for key #{trocla_key} in trocla")

        # HERE BE DRAGONS: hiera lookups from backend to determine additional
        # trocla options for this password
        format = Backend.lookup(options_namespace + trocla_key + '::format',
                                @default_format, scope, nil, :priority)

        answer = nil
        # Go looking for existing password as hiera/<source>/<trocla_key>.
        # Would need to be initialised externally, e.g by calling
        # trocla('hiera/osfamily/Debian/jessie/root' in site.pp.  Alternatively
        # we could use hiera's concept of datafiles to look into different
        # trocla password stores. But this would need somehow providing
        # different troclarcs as well.
        sources = Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          break if answer = @trocla.send(:get_password,
                                         'hiera/' + source + '/' + trocla_key,
                                         format)
        end

        if not answer
          # create a new password
          options = Backend.lookup(options_namespace + trocla_key + '::options',
                                   @default_options, scope, nil, :hash)
          answer = @trocla.send(:password, trocla_key, format, options)
        end

        return answer
      end

    end
  end
end
