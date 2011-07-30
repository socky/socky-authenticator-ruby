require 'json'
require 'digest/md5'
require 'hmac-sha2'

module Socky
  class Authenticator
    DEFAULT_RIGHTS = {
      'read' => true,
      'write' => false,
      'hide' => false
    }
    
    class << self
      attr_accessor :secret
      
      def authenticate(params, allow_changing_rights = false, secret = nil)
        self.new(params, allow_changing_rights, secret).result
      end
    end
    
    attr_accessor :secret, :salt
    
    def initialize(params, allow_changing_rights = false, secret = nil)
      @params = (params.is_a?(String) ? JSON.parse(params) : params) rescue nil
      raise ArgumentError, 'Expected hash or JSON' unless @params.kind_of?(Hash)
      @secret = secret || self.class.secret
      @allow_changing_rights = allow_changing_rights
    end
    
    def result
      raise ArgumentError, 'set Authenticator.secret first' unless self.secret
      raise ArgumentError, 'expected connection_id' unless self.connection_id
      raise ArgumentError, 'expected channel' unless self.channel_name
      raise ArgumentError, 'user are not allowed to change channel rights' unless self.rights
      
      r = { 'auth' => auth }
      r.merge!('data' => user_data) unless user_data.nil?
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
      args << user_data unless user_data.nil?
      args.collect(&:to_s).join(":")
    end
    
    def salt
      @salt ||= Digest::MD5.hexdigest(rand.to_s)
    end
    
    def connection_id
      @params['connection_id']
    end
    
    def channel_name
      @params['channel']
    end
    
    def rights
      return @rights if defined?(@rights)
      r = DEFAULT_RIGHTS.merge(@params)
      
      # Return nil if user is trying to change rights when this option is disabled
      return nil if !@allow_changing_rights && DEFAULT_RIGHTS.any?{ |right,val| r[right] != val }
      
      @rights = ['read', 'write', 'hide'].collect do |right|
        r[right] && !(right == 'hide' && !self.presence?) ? '1' : '0'
      end.join
    end
    
    def user_data
      @user_data ||= case @params['data']
        when NilClass then nil
        when String then @params['data']
        else @params['data'].to_json
      end
    end
    
    def presence?
      self.channel_name.is_a?(String) && !!self.channel_name.match(/\Apresence-/)
    end
    
  end
end