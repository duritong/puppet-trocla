module Puppet::Parser::Functions
  newfunction(:trocla, :type => :rvalue) do |*args|
    require File.dirname(__FILE__) + '/../../util/trocla_helper'
    
    Puppet::Util::TroclaHelper.trocla(:password,true,*args)
  end
end