module Puppet::Util::TroclaHelper
  def trocla(trocla_func,has_options,*args)
    # Functions called from puppet manifests that look like this:
    #   lookup("foo", "bar")
    # internally in puppet are invoked:  func(["foo", "bar"])
    #
    # where as calling from templates should work like this:
    #   scope.function_lookup("foo", "bar")
    #
    #  Therefore, declare this function with args '*args' to accept any number
    #  of arguments and deal with puppet's special calling mechanism now:
    if args[0].is_a?(Array)
        args = args[0]
    end

    key = args[0] || raise(Puppet::ParseError, "You need to pass at least a key as an argument!")
    format = args[1] || 'plain'
    options = args[2] || {}

    if options.is_a?(String)
      require 'yaml'
      options = YAML.load(options)
    end

    r = has_options ? store.send(trocla_func, key, format, options) : store.send(trocla_func, key, format)
    store.close
    r
  end
  module_function :trocla

  private

  def store
    @store ||= begin
      require 'trocla'
      configfile = File.join(File.dirname(Puppet.settings[:config]), "troclarc.yaml")

      raise(Puppet::ParseError, "Trocla config file #{configfile} is not readable") unless File.exist?(configfile)

      Trocla.new(configfile)
    end
  end
  module_function :store

end
