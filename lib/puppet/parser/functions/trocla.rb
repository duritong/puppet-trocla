module Puppet::Parser::Functions
  newfunction(:trocla, :type => :rvalue, :doc => "
This will create or get a random password from the trocla storage.

Usage:

    $password_user1 = trocla(key,[format='plain'[,options={}]])

Means:

    $password_user1 = trocla('user1')

Create or get the plain text password for the key 'user1'

    $password_user2 = trocla('user2','mysql')

Create or get the mysql style sha1 hashed password.

    $options_user3 = { 'username' => 'user3' } # Due to a puppet bug
                                               # this needs to be assigned
                                               # like that.
    $password_user3 = trocla('user3','pgsql', $options_user3)

Options can also be passed as a yaml string:

    $password_user3 = trocla('user3','pgsql', \"username: 'user3'\")
  "
  ) do |*args|
    if args[0].is_a?(Array)
        args = args[0]
    end

    key = args[0] || raise(Puppet::ParseError, "You need to pass at least a key as an argument!")
    format = args[1] || 'plain'
    options = args[2] || {}
    result = nil

    # you can give options as YAML string or as a hash
    # if it's a string, we need to parse it
    if options.is_a?(String)
      require 'yaml'
      options = YAML.load(options)
    end

    configfile = lookupvar('trocla_configfile') || File.join(Puppet.settings[:confdir], "troclarc.yaml")
    raise(Puppet::ParseError, "Trocla config file #{configfile} is not readable") unless File.exist?(configfile)

    require 'trocla'
    Trocla.open(configfile) { |t|
      result = t.password(key, format, options)
    }

    result
  end
end
