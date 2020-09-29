# The `trocla_lookup_key` is a hiera 5 `lookup_key` data provider function.
# See [the configuration guide documentation](https://docs.puppet.com/puppet/latest/hiera_config_yaml_5.html#configuring-a-hierarchy-level-hiera-trocla) for
# how to use this function.
#
# @since 5.0.0
#
Puppet::Functions.create_function(:trocla_lookup_key) do
  require 'trocla'

  dispatch :trocla_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def trocla_lookup_key(key, options, context)
    # return immediately if this is no trocla lookup
    unless key =~ /^trocla_lookup::/ || key =~ /^trocla_hierarchy::/
      context.not_found
      return
    end

    return context.cached_value(key) if context.cache_has_key(key)

    # use the nil cache to store trocla object
    @trocla = context.cached_value(nil) || context.cache(nil,init(options))

    method, format, trocla_key = key.split('::', 3)
    opts = options(trocla_key, format, options['trocla_hierarchy'], context)
    res = if method == 'trocla_lookup'
      trocla_lookup(trocla_key, format, opts)
    else # trocla_hierarchy
      trocla_hierarchy(trocla_key, format, opts)
    end

    @trocla.close

    context.not_found unless res
    context.cache(key, res)
  end

  # This is a simple lookup which will return a password for the key
  def trocla_lookup(trocla_key, format, opts)
    @trocla.password(opts.delete('trocla_key')||trocla_key, format, opts)
  end

  def trocla_hierarchy(trocla_key, format, opts)
    tk = opts.delete('trocla_key') || trocla_key
    get_password_from_hierarchy(tk, format, opts) ||
      set_password_in_hierarchy(tk, format, opts)
  end

  # Try to retrieve a password from a hierarchy
  def get_password_from_hierarchy(trocla_key, format, opts)
    answer = nil
    Array(opts['trocla_hierarchy']).each do |source|
      key = hierarchical_key(source, trocla_key)
      answer = @trocla.get_password(key, format, opts)
      break unless answer.nil?
    end
    answer
  end

  # Set the password in the hierarchy at the top level or the
  # level that is specified in the options hash with 'order_override'
  def set_password_in_hierarchy(trocla_key, format, opts)
    answer = nil
    Array(Array(opts['order_override'])|opts['trocla_hierarchy']).each do |source|
      key = hierarchical_key(source, trocla_key)
      answer = @trocla.password(key, format, opts)
      break unless answer.nil?
    end
    answer
  end

  def hierarchical_key(source, trocla_key)
    "hiera/#{source}/#{trocla_key}"
  end

  # retrieve options hash and merge the format specific settings into the defaults
  def options(trocla_key, format, trocla_hierarchy, context)
    g_options = {'trocla_hierarchy' => trocla_hierarchy||[]}.merge(global_options(format,context))
    k_options = key_options(trocla_key, format, context)
    g_options.merge(k_options)
  end

  # returns global options for password generation
  def global_options(format,context)
    g_options = lookup_options('trocla_options')
    context.interpolate(g_options.merge(g_options[format] || {}))
  end

  # returns per key options for password generation
  def key_options(trocla_key, format, context)
    k_options = lookup_options('trocla_options::' + trocla_key)
    context.interpolate(k_options.merge(k_options[format] || {}))
  end

  def lookup_options(key)
    call_function('lookup', key, Puppet::Pops::Types::PHashType::DEFAULT, 'hash', {})
  end

  def init(options)
    # Can't do this with an argument_mismatch dispatcher since there is no way to declare a struct that at least
    # contains some keys but may contain other arbitrary keys.
    unless options.include?('config')
      raise ArgumentError,
        "'trocla_lookup_key': config must be declared in options of hiera.yaml when using this lookup_key function"
    end
    unless options.include?('trocla_hierarchy') && !options['trocla_hierarchy'].empty?
      raise ArgumentError,
        "'trocla_lookup_key': :trocla_hierarchy must be declared in trocla hierarchy of hiera.yaml when using this lookup_key function"
    end
    @trocla = ::Trocla.new(options['config'])
  end
end

