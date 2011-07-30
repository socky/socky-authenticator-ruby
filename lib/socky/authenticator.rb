require 'json'
require 'digest/md5'
require 'hmac-sha2'

module Socky
  class Authenticator
    DEFAULT_RIGHTS = {
      :read => true,
      :write => false,
      :hide => false
    }
    
    class << self
      attr_accessor :secret
      
      def authenticate(params, opts = {})
        self.new(params, opts).result
      end
    end
    
    attr_accessor :secret, :salt, :method
    
    def initialize(params, opts = {})
      @params = (params.is_a?(String) ? JSON.parse(params) : params) rescue nil
      raise ArgumentError, 'Expected hash or JSON' unless @params.kind_of?(Hash)
      @secret = opts[:secret] || opts['secret'] || self.class.secret
      @method = opts[:method] || opts['method'] || :websocket
      @allow_changing_rights = opts[:allow_changing_rights] || false
    end
    
    def result
      raise ArgumentError, 'set Authenticator.secret first' unless self.secret
      raise ArgumentError, 'expected connection_id' unless self.connection_id
      raise ArgumentError, 'expected channel' unless self.channel
      raise ArgumentError, 'expected event' unless self.method != :http || self.event
      
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
      args = [salt, connection_id, channel]
      args << (@method == :websocket ? rights_string : event.to_s)
      args << user_data unless user_data.nil?
      args.collect(&:to_s).join(":")
    end
    
    def salt
      @salt ||= Digest::MD5.hexdigest(rand.to_s)
    end
    
    def connection_id
      @params[:connection_id] || @params['connection_id']
    end
    
    def channel
      @params[:channel] || @params['channel']
    end
    
    def event
      @params[:event] || @params['event']
    end
        
    def rights
      {
        :read => read_right,
        :write => write_right,
        :hide => hide_right
      }
    end
    
    def user_data
      @user_data ||= case (@params[:data] || @params['data'])
        when NilClass then nil
        when String then @params['data']
        else @params['data'].to_json
      end
    end
    
    def presence?
      self.channel.is_a?(String) && !!self.channel.match(/\Apresence-/)
    end
    
    private
    
    def read_right
      return DEFAULT_RIGHTS[:read] unless @allow_changing_rights
      [ @params[:read], @params['read'], DEFAULT_RIGHTS[:read] ].reject(&:nil?).first
    end
    
    def write_right
      return DEFAULT_RIGHTS[:write] unless @allow_changing_rights
      [ @params[:write], @params['write'], DEFAULT_RIGHTS[:write] ].reject(&:nil?).first
    end
    
    def hide_right
      return DEFAULT_RIGHTS[:hide] unless self.presence? && @allow_changing_rights
      [ @params[:hide], @params['hide'], DEFAULT_RIGHTS[:hide] ].reject(&:nil?).first
    end
    
    def rights_string
      [ rights[:read], rights[:write], rights[:hide] ].collect do |right|
        right ? '1' : '0'
      end.join
    end
    
  end
end