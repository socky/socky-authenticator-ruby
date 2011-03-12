require 'spec_helper'

describe Socky::Authenticator do
  
  # Set authenticator secret
  before { Socky::Authenticator.secret = 'application_secret_key' }
  
  subject { Socky::Authenticator.new('connection_id' => '1234ABCD', 'channel' => 'some_channel') }
  # Set salt to constant to make tests non-random
  before { subject.instance_variable_set('@salt', 'somerandomstring') }
  
  its(:salt) { should eql('somerandomstring') }
  its(:connection_id) { should eql('1234ABCD') }
  its(:channel_name) { should eql('some_channel') }
  its(:rights) { should eql('100') }
  its(:presence?) { should eql(false) }
  its(:string_to_sign) { should eql('somerandomstring:1234ABCD:some_channel:100')}
  its(:signature) { should eql('28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d') }
  its(:auth) { should eql('somerandomstring:28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d') }
  its(:result) { should eql('auth' => 'somerandomstring:28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d')}
  
end