#
# hostname_to_cidr.rb
#

require 'resolv'

module Puppet::Parser::Functions
  newfunction(:hostname_to_cidr, :type => :rvalue, :doc => <<-EOS
This function takes a hostname and returns the CIDR equiv
new keys are the old array elements.


*Examples:*
    hostname_to_cidr('localhost.example.com')
Would return
'127.0.0.1/31'
    EOS
  ) do |arguments|

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "hostname_to_cidr(): Wrong number of arguments given #{arguments.size} for 1")
    elsif !(arguments[0].kind_of?(String)) then
      raise(Puppet::ParseError, "hostname_to_cidr(): requires a string")
    end

    retval = Resolv.getaddress arguments[0]

    return "#{retval}/32"

  end
end

# vim: set ts=2 sw=2 et :

