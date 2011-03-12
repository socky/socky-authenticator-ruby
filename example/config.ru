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
    if request.params['callback']
      body = request.params['callback'].to_s + '(' + response.to_json + ');'
    else
      body = response.to_json
    end
    
    [
      200,
      {
        'Content-Type' => 'text/javascript',
      },
      body
    ]
  else
    [ 400, {}, []]
  end
end

use Rack::CommonLogger

map '/socky/auth' do
  run app
end