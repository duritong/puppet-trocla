# frozen_string_literal: true

# @summary Set a password/hash and return it as-is or hashed in a different format.
#
# The function operates on two different formats, one for the value of the
# password and one for the return value. By default the return format is set to
# be the same as the value format.
#
# If the password is present in plaintext, either as the value format or if it
# was already there in local storage, it can be rehashed into a different,
# return format that the function then returns.
#
# This function is mainly useful to migrate from hashes in manifests to trocla
# only manifests.
#
# Usage:
#
#     $password_user1 = trocla_set(key,value,[format='plain',[return_format,[options={}]]])
#
# @example Set and return 'mysecret' as plain password.
#     $password_user1 = trocla_set('user1','mysecret')
#
# @example Set and return the sha1 hashed mysql password for the key user2.
#     $password_user2 = trocla_set('user2','*AAA...','mysql')
#
# @example Set 'mysecret' as plain password, but return a newly created
#   sha512crypt hash.
#     $password_user3 = trocla_set('user3','mysecret','plain','sha512crypt')
#
# @example Set the plain password 'mysecret' and return a pgsql md5 hash for
#   user4.
#     $postgres_user4 = { username => 'user4' }
#     $password_user4 = trocla_set('user4','mysecret','plain','pgsql',$postgres_user4)
#
# @example This will likely fail, except if you add the plain password or the
#   sha512crypt hash manually to trocla, for example via cli.
#     $password_user2 = trocla_set('user2','*AAA...','mysql','sha512crypt')
#
Puppet::Functions.create_function(:trocla_set) do
  require 'trocla'

  dispatch :trocla_set do
    param 'String', :key
    param 'String', :value
    optional_param 'String', :format
    optional_param 'String', :return_format
    optional_param 'Variant[String, Hash[String, Any]]', :options
    return_type 'String'
  end

  def trocla_set(key, value, format = 'plain', return_format = nil, options = {})
    return_format = format if return_format.nil?

    configfile = File.join(File.dirname(Puppet.settings[:config]), 'troclarc.yaml')

    raise(Puppet::ParseError, "Trocla config file #{configfile} not readable") unless File.exist?(configfile)

    result = (trocla = Trocla.new(configfile)).set_password(key, format, value)
    if format != return_format && (result = trocla.get_password(key, return_format)).nil?
      raise(Puppet::ParseError, "Plaintext password is not present, but required to return password in format #{return_format}") if (return_format == 'plain') || trocla.get_password(key, 'plain').nil?

      result = trocla.password(key, return_format, options.dup)
    end
    trocla.close
    result
  end
end
