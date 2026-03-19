# frozen_string_literal: true

# @summary Get an already stored password from the trocla storage.
#
# This function will not create a new password if the key does not exist. By
# default requesting an unknown key will raise a parse error.
#
# Usage:
#
#     $password_user1 = trocla_get(key,[format='plain'[,raise_error=true]])
#
# @example Get the plain text password for the key 'user1'.
#     $password_user1 = trocla('user1')
#
# @example Get the mysql style sha1 hashed password.
#     $password_user2 = trocla_get('user2','mysql')
#
# @example Get the x509 style private key, by passing any trocla options as a
#   third argument.
#     $cert_x509_key = trocla_get('cert_x509','x509', 'render: keyonly')
#
# @example Disable raising an error on unknown key. The function will return
#   undef instead.
#     $password_user3 = trocla_get('user2','mysql',false)
# @example Disable raising an error using a hash
#     $password_user3 = trocla_get('user2','mysql', { raise_error => false })
# @example Disable raising an error using a yaml string
#     $password_user3 = trocla_get('user2','mysql', 'raise_error: false')
#
Puppet::Functions.create_function(:trocla_get) do
  require "#{File.dirname(__FILE__)}/../util/trocla_helper"

  dispatch :trocla_get do
    param 'String', :key
    optional_param 'String', :format
    optional_param 'Variant[Boolean, String, Hash[String, Any]]', :options
    return_type 'Variant[String, Undef]'
  end

  def trocla_get(key, format = 'plain', options = {})
    if options.nil?
      raise_error = true
      options = {}
    elsif [TrueClass, FalseClass].include?(options.class)
      raise_error = options
      options = {}
    else
      options = YAML.safe_load(options) if options.is_a?(String)
      raise(Puppet::ParseError, 'Third argument to trocla_get must either be a boolean, yaml string or a hash') unless options.is_a?(Hash)

      raise_error = options.key?('raise_error') ? options.dup.delete('raise_error') : true
    end

    has_options = !options.empty?
    if (answer = Puppet::Util::TroclaHelper.trocla(:get_password, has_options, [key, format, options])).nil? && raise_error
      raise(Puppet::ParseError, "No password found for key=#{key}, format=#{format}!")
    end

    answer.nil? ? :undef : answer
  end
end
