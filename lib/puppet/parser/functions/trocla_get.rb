module Puppet::Parser::Functions
  newfunction(:trocla_get, :type => :rvalue, :doc => "
  This will only get an already stored password from the trocla storage.

Usage:

    $password_user1 = trocla_get(key,[format='plain'[,raise_error=true]])

Means:

    $password_user1 = trocla('user1')

Get the plain text password for the key 'user1'

    $password_user2 = trocla_get('user2','mysql')

Get the mysql style sha1 hashed password.

By default puppet will raise a parse error if the password haven't yet been
stored in trocla. This can be turned off by setting false as a third argument:

    $password_user3 = trocla_get('user2','mysql',false)

the return value will be undef if the key & format pair is not found.
"
  ) do |*args|

    # handle puppets weird call semantics
    if args[0].is_a?(Array)
        args = args[0]
    end

    key = args[0] || raise(Puppet::ParseError, "You need to pass at least a key as an argument!")
    format = args[1] || 'plain'
    raise_error = args[2] || false
    result = nil

    configfile = lookupvar('trocla_configfile') || File.join(File.dirname(Puppet.settings[:config]), "troclarc.yaml")
    raise(Puppet::ParseError, "Trocla config file #{configfile} is not readable") unless File.exist?(configfile)

    require 'trocla'
    Trocla.open(configfile) { |t|
      result = t.get_password(key, format)
    }

    raise(Puppet::ParseError, "No password for key,format #{args[0..1].flatten.inspect} found!") if raise_error && result.nil?

    result
  end
end
