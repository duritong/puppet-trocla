# frozen_string_literal: true

# The `trocla_gsub` replaces %%TROCLA_[\w_\-]+%% place holders with
# data looked up in trocla
#
Puppet::Functions.create_function(:'trocla::gsub') do
  dispatch :trocla_gsub do
    param 'String', :data
    optional_param 'Struct[{ prefix => Optional[String], key_to_prefix => Optional[Hash[String,String]] }]', :options
    return_type 'String'
  end

  def trocla_gsub(data, options = {})
    res = data.dup
    trocla_keys = res.scan(%r{%%TROCLA_[\w_\-.@]+%%})
    trocla_keys.each do |k|
      tk = k.match(/%%TROCLA_([\w_\-\.@]+)%%/)[1]
      if options['key_to_prefix'].is_a?(Hash) && (prefix = options['key_to_prefix'][tk])
        trocla_key = "#{prefix}#{tk}"
      else
        trocla_key = "#{options['prefix']}#{tk}"
      end
      trocla_val = call_function('trocla', trocla_key ,'plain')
      res = res.gsub(k,trocla_val)
    end
    res
  end
end
