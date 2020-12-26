# The `trocla_gsub` replaces %%TROCLA_[\w_\-]+%% place holders with
# data looked up in trocla
#
Puppet::Functions.create_function(:'trocla::gsub') do
  dispatch :trocla_gsub do
    param 'String', :data
    optional_param 'Struct[{ prefix => Optional[String] }]', :options
  end

  def trocla_gsub(data,options={})
    res = data.dup
    trocla_keys = res.scan(/%%TROCLA_[\w_\-]+%%/)
    trocla_keys.each do |k|
      tk = k.match(/%%TROCLA_([\w_\-]+)%%/)[1]
      trocla_key = "#{options['prefix']}#{tk}"
      trocla_val = call_function('trocla', trocla_key ,'plain')
      res = res.gsub(k,trocla_val)
    end
    res
  end
end

