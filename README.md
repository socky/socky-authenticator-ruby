# Socky Authentication Module

## Installation

    gem install socky-authenticator

## Usage

First require authenticator:

    require 'socky/authenticator'

After that call:

    Socky::Authenticator.authenticate(<data>)

where \<data\> is Socky Client authentication data in Hash or JSON-encoded Hash format.

In return you will receive authentication Hash in format:
    
    { 'auth' => <auth_data> }

If any error occurs then authenticator will raise ArgumentError with explanation.

If you are validating presence channel then except auth data you will receive user data in JSON-encoded format:

    { 'auth' => <auth_dat>, 'data' => <json-encoded_user_data> }

## Configuration

Before authenticating request you will need to provide application secret. If you are using only one Socky application in code then you can set it once using:

    Socky.secret = <secret>

Otherwise you will need to provide secret each time when authenticating data.

Except of that you can enable or disable authenticaton of user rights - if disabled(default) then user will not be able to change their rights. Full version of authenticator call will look like that:

    Socky::Authenticator.authenticate(<data>, allow_changing_rights, secret)
