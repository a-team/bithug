require 'net/ldap'

module Bithug::Authentication
  module LDAP

    def initialize(options={})
      @ldap = Net::LDAP.new :host => (options[:host] || "nads2"),
      :port => (options[:port] || 389)
    end

    def authenticate(username, password)
      @ldap.auth username, password
      @ldap.bind || super
    end
  end
end
