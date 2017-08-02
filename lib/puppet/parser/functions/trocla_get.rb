module Puppet::Parser::Functions
  newfunction(:trocla_get, :type => :rvalue, :doc => "
  This will only get an already stored password from the trocla storage.

Usage:

    $password_user1 = trocla_get(key,[format='plain'[,options=nill[,raise_error=true]])

Means:

    $password_user1 = trocla('user1')

Get the plain text password for the key 'user1'

    $password_user2 = trocla_get('user2','mysql')

Get the mysql style sha1 hashed password.

    $cert_x509_key = trocla_get('cert_x509','x509', 'render: keyonly')

Get the x509 style private key.

By default puppet will raise a parse error if the password haven't yet been
stored in trocla. This can be turned off by setting false as a third argument:

    $password_user3 = trocla_get('user2','mysql',nill,false)

the return value will be undef if the key & format pair is not found.
"
  ) do |*args|
    if args[0].is_a?(Array)
        args = args[0]
    end
    require File.dirname(__FILE__) + '/../../util/trocla_helper'
    args[1] ||= 'plain'
    options = args[2] || {}
    raise_error = args[3].nil? ? true : args[3]
    raise(Puppet::ParseError, "Trocla parsing ordering change, for disable raise_error use trocla_get('user2','mysql',nill,false)") if (options.is_a?(FalseClass) || options.is_a?(TrueClass))
    if (answer=Puppet::Util::TroclaHelper.trocla(:get_password,false,[args[0],args[1],options])).nil? && raise_error
      raise(Puppet::ParseError, "No password for key,format #{args[0..1].flatten.inspect} found!")
    end
    answer.nil? ? :undef : answer
  end
end
