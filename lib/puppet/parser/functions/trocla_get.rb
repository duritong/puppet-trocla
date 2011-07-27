module Puppet::Parser::Functions
  newfunction(:trocla_get, :type => :rvalue) do |*args|
    require File.dirname(__FILE__) + '/../../util/trocla_helper'
    if (answer=Puppet::Util::TroclaHelper.trocla(:get_password,false,*args)).nil?
      raise(Puppet::ParseError, "No password for key,format #{args.flatten.inspect} found!")
    end
    answer
  end
end