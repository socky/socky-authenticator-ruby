# Socky Authentication Module [![](https://travis-ci.org/socky/socky-authenticator-ruby.png)](http://travis-ci.org/socky/socky-authenticator-ruby)

## Installation

``` bash
$ gem install socky-authenticator
```

## Usage

First require authenticator:

``` ruby
require 'socky/authenticator'
```

After that call:

``` ruby
Socky::Authenticator.authenticate(<data>)
```

where \<data\> is Socky Client authentication data in Hash or JSON-encoded Hash format.

In return you will receive authentication Hash in format:

``` ruby
{ 'auth' => <auth_data> }
```

If any error occurs then authenticator will raise ArgumentError with explanation.

If you are validating presence channel then except auth data you will receive user data in JSON-encoded format:

``` ruby
{ 'auth' => <auth_dat>, 'data' => <json-encoded_user_data> }
```

## Configuration

Before authenticating request you will need to provide application secret. If you are using only one Socky application in code then you can set it once using:

``` ruby
Socky::Authenticator.secret = <secret>
```

Otherwise you will need to provide secret each time when authenticating data.

Except of that you can enable or disable authenticaton of user rights - if disabled(default) then user will not be able to change their rights. Full version of authenticator call will look like that:

``` ruby
Socky::Authenticator.authenticate(<data>, :allow_changing_rights => true, :secret => 'mysecret')
```

## License

(The MIT License)

Copyright (c) 2011 Bernard Potocki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
