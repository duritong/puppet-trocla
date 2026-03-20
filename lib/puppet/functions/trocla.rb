# frozen_string_literal: true

# @summary Create or get a random password from the trocla storage.
#
# Usage:
#
#     $password_user1 = trocla(key,[format='plain'[,options={}]])
#
# @example Create or get the plain text password for the key 'user1'
#     $password_user1 = trocla('user1')
#
# @example Create or get the mysql style sha1 hashed password.
#     $password_user2 = trocla('user2','mysql')
#
# @example Passing options
#     $options_user3 = { 'username' => 'user3' } # Due to a puppet bug
#                                                # this needs to be assigned
#                                                # like that.
#     $password_user3 = trocla('user3','pgsql', $options_user3)
#
# @example Options can also be passed as a yaml string
#     $password_user3 = trocla('user3','pgsql', \"username: 'user3'\")
#
Puppet::Functions.create_function(:trocla) do
  require 'puppet/util/trocla_helper'

  dispatch :trocla do
    param 'String', :key
    optional_param 'String', :format
    optional_param 'Hash[String, Any]', :options
    return_type 'String'
  end

  def trocla(key, format = 'plain', options = {})
    Puppet::Util::TroclaHelper.trocla(:password, true, key, format, options)
  end
end
