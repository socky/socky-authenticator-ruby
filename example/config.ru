require 'json'
require 'lib/socky/authenticator'

Socky::Authenticator.secret = 'my_secret'

app = proc do |env|
  request = Rack::Request.new(env)
  
  begin
    response = Socky::Authenticator.authenticate(request.params['payload'])
  rescue ArgumentError => e
    puts e.message
    response = nil
  end
  
  if response
    [
      200,
      {
        'Content-Type' => 'text/javascript',
      },
      response.to_json
    ]
  else
    [ 400, {}, []]
  end
end

use Rack::CommonLogger

map '/socky/auth' do
  run app
end