require 'json'
require 'md5'
require 'hmac-sha2'

module Socky
  class Authenticator
    VERSION = '0.5.0.beta2'
    
    DEFAULT_RIGHTS = {
      'read' => true,
      'write' => false,
      'hide' => false
    }
    
    class << self
      attr_accessor :secret
      
      def authenticate(args = {}, allow_changing_rights = false, secret = nil)
        self.new(args, allow_changing_rights, secret).result
      end
    end
    
    attr_accessor :secret, :salt
    
    def initialize(args = {}, allow_changing_rights = false, secret = nil)
      @args = (args.is_a?(String) ? JSON.parse(args) : args) rescue nil
      raise ArgumentError, 'Expected hash or JSON' unless @args.kind_of?(Hash)
      @secret = secret || self.class.secret
      @allow_changing_rights = allow_changing_rights
    end
    
    def result
      raise ArgumentError, 'set Authenticator.secret first' unless self.secret
      raise ArgumentError, 'expected connection_id' unless self.connection_id
      raise ArgumentError, 'expected channel' unless self.channel_name
      raise ArgumentError, 'user are not allowed to change channel rights' unless self.rights
      
      r = { 'auth' => auth }
      r.merge!('data' => user_data) if self.presence?
      r
    end
    
    def auth
      [salt, signature].join(':')
    end
    
    def signature
      HMAC::SHA256.hexdigest(self.secret, string_to_sign)
    end
    
    def string_to_sign
      args = [salt, connection_id, channel_name, rights]
      args << user_data if presence?
      args.collect(&:to_s).join(":")
    end
    
    def salt
      @salt ||= MD5.new(rand.to_s).to_s
    end
    
    def connection_id
      @args['connection_id']
    end
    
    def channel_name
      @args['channel']
    end
    
    def rights
      return @rights if defined?(@rights)
      r = DEFAULT_RIGHTS.merge(@args)
      
      # Return nil if user is trying to change rights when this option is disabled
      return nil if !@allow_changing_rights && DEFAULT_RIGHTS.any?{ |right,val| r[right] != val }
      
      @rights = ['read', 'write', 'hide'].collect do |right|
        r[right] && !(right == 'hide' && !self.presence?) ? '1' : '0'
      end.join
    end
    
    def user_data
      @user_data ||= (@args['data'].is_a?(String) ? @args['data'] : @args['data'].to_json)
    end
    
    def presence?
      self.channel_name.is_a?(String) && !!self.channel_name.match(/\Apresence-/)
    end
    
  end
end