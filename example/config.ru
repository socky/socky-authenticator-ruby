require 'rack'
require 'json'
require File.expand_path(File.dirname(__FILE__)) + '/../lib/socky/authenticator'

Socky::Authenticator.secret = 'my_secret'

authenticator = proc do |env|
  request = Rack::Request.new(env)

  response = Socky::Authenticator.authenticate(request.params, true)
  body = request.params['callback'].to_s + '(' + response.to_json + ');'
  [ 200, {}, body ]
end


map '/socky/auth' do
  run authenticator
end
