# Custom hiera backend for trocla
#
# Only reacts to key namespace trocla::password::<trocla_key>. Looks up
# additional parameters via hiera itself as
# trocla::options::<trocla_key>::format (string) and
# trocla::options::<trocla_key>::options (hash). Looks for <trocla_key> in
# trocla as hiera/<source>/<trocla> with <source> iterating over the configured
# hiera hierarchy. If not found, makes a normal trocla lookup with
# <trocla_key> that might create a new password on the first run.
#
# example entry in hiera.yaml:
# backends:
#   - ...
#   - trocla
# trocla:
#   configfile: /etc/puppet/troclarc.yaml
#   default_format: plain
#   default_options:
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
      attr_accessor :trocla
      def initialize
        Hiera.debug("Hiera Trocla backend starting")
        require 'trocla'
        unless File.readable?(config[:configfile])
          Hiera.warn("Trocla config file #{config[:configfile]} is not readable")
          return
        end

        @trocla = Trocla.new(config[:configfile])
      end

      def lookup(key, scope, order_override, resolution_type)
        return nil unless trocla

        Hiera.debug("Looking up #{key} in trocla backend")


        # we only accept trocla::password:: lookups because we do hiera lookups
        # ourselves and could otherwise cause loops
        return nil unless key.start_with?(config[:password_namespace])

        # cut off trocla hiera namespace: trocla::password::root -> root
        trocla_key = key.sub(/^#{config[:password_namespace]}/,'')
        Hiera.debug("Looking for key #{trocla_key} in trocla")

        # HERE BE DRAGONS: hiera lookups from backend to determine additional
        # trocla options for this password
        format = Backend.lookup(config[:options_namespace] + trocla_key + '::format',
                                config[:default_format], scope, nil, :priority)

        answer = nil
        # Go looking for existing password as hiera/<source>/<trocla_key>.
        # Would need to be initialised externally, e.g by calling
        # trocla('hiera/osfamily/Debian/jessie/root' in site.pp.  Alternatively
        # we could use hiera's concept of datafiles to look into different
        # trocla password stores. But this would need somehow providing
        # different troclarcs as well.
        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          break if answer = trocla.get_password(
                                      'hiera/' + source + '/' + trocla_key,
                                      format)
        end

        unless answer
          # lookup and maybe create a new password
          options = Backend.lookup(config[:options_namespace] + trocla_key + '::options',
                                   config[:default_options], scope, nil, :hash)
          answer = trocla.password(trocla_key, format, options)
        end

        return answer
      end

      private
      def config
        @config ||= {
            :configfile         => '/etc/puppet/troclarc.yaml',
            :default_format     => 'plain',
            :default_options    => {},
            :password_namespace => 'trocla::password::',
            :options_namespace  => 'trocla::options::',
        }.merge(Config[:trocla] || {})
      end
    end
  end
end
