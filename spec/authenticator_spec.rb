require 'spec_helper'

describe Socky::Authenticator do
  
  # Set authenticator secret
  before { Socky::Authenticator.secret = 'application_secret_key' }
  
  it "should raise exception on invalid data" do
    lambda { Socky::Authenticator.new("invalid") }.should raise_error ArgumentError, "Expected hash or JSON"
  end
  
  it "should allow passing Hash" do
    subject = Socky::Authenticator.new('some' => 'data')
    subject.instance_variable_get('@args').should eql('some' => 'data')
  end
  
  it "should allow passing JSON-encoded Hash" do
    subject = Socky::Authenticator.new('{"some":"data"}')
    subject.instance_variable_get('@args').should eql('some' => 'data')
  end
  
  it "should raise on JSON-encoded non-Hash" do
    lambda { Socky::Authenticator.new('["some","data"]') }.should raise_error ArgumentError, "Expected hash or JSON"
  end
  
  context "instance" do
    subject { Socky::Authenticator.new('connection_id' => '1234ABCD', 'channel' => 'some_channel') }
    # Set salt to constant to make tests non-random
    before { subject.salt =  'somerandomstring' }
  
    its(:salt) { should eql('somerandomstring') }
    its(:connection_id) { should eql('1234ABCD') }
    its(:channel_name) { should eql('some_channel') }
    its(:rights) { should eql('100') }
    its(:presence?) { should eql(false) }
    its(:string_to_sign) { should eql('somerandomstring:1234ABCD:some_channel:100') }
    its(:signature) { should eql('28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d') }
    its(:auth) { should eql('somerandomstring:28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d') }
    its(:result) { should eql('auth' => 'somerandomstring:28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d') }
  
    it "should raise if authenticator secret is nil" do
      subject.secret = nil
      lambda { subject.result }.should raise_error ArgumentError, 'set Authenticator.secret first'
    end
  
    it "should raise if connection_id is nil" do
      subject.instance_variable_get('@args').delete('connection_id')
      subject.connection_id.should be_nil
      lambda { subject.result }.should raise_error ArgumentError, 'expected connection_id'
    end
  
    it "should raise if channel is nil" do
      subject.instance_variable_get('@args').delete('channel')
      subject.channel_name.should be_nil
      lambda { subject.result }.should raise_error ArgumentError, 'expected channel'
    end
  
    it "should not allow to changing rights at default" do
      subject.instance_variable_get('@args').merge!('write' => true)
      subject.rights.should be_nil
      lambda { subject.result }.should raise_error ArgumentError, 'user are not allowed to change channel rights'
    end
  
    it "should ignore user data when not presence channel" do
      subject.instance_variable_get('@args').merge!('data' => {'some' => 'data' })
      subject.string_to_sign.should eql('somerandomstring:1234ABCD:some_channel:100')
      subject.result.should eql('auth' => 'somerandomstring:28f138d68b1d4971d85355a5aa5a301be9084176b6ae1bbe2399de990de2039d')
    end
  
    context "with changing rights enables" do
      before { subject.instance_variable_set('@allow_changing_rights', true) }
    
      it "should allow changing 'read' to false" do
        subject.instance_variable_get('@args').merge!('read' => false)
        subject.rights.should eql('000')
      end
    
      it "should allow changing 'write' to true" do
        subject.instance_variable_get('@args').merge!('write' => true)
        subject.rights.should eql('110')
      end
    
      it "should not allow changing 'hide' to true" do
        subject.instance_variable_get('@args').merge!('hide' => true)
        subject.rights.should eql('100')
      end
    
    end
  
    context "presence channel" do
      before { subject.instance_variable_get('@args').merge!('channel' => 'presence-channel') }
    
      its(:channel_name) { should eql('presence-channel') }
      its(:rights) { should eql('100') }
      its(:presence?) { should eql(true) }
      its(:user_data) { should eql('null') }
      its(:string_to_sign) { should eql('somerandomstring:1234ABCD:presence-channel:100:null') }
      its(:signature) { should eql('3cf543ceba1260b74e891144ea59ebb85b397de2c0172b00833dcbf62cd346d1') }
      its(:auth) { should eql('somerandomstring:3cf543ceba1260b74e891144ea59ebb85b397de2c0172b00833dcbf62cd346d1') }
      its(:result) { should eql('auth' => 'somerandomstring:3cf543ceba1260b74e891144ea59ebb85b397de2c0172b00833dcbf62cd346d1', 'data' => 'null') }
    
      context "with user data provided" do
        before { subject.instance_variable_get('@args').merge!('data' => { 'some' => 'data' }) }
      
        its(:user_data) { should eql('{"some":"data"}') }
        its(:string_to_sign) { should eql('somerandomstring:1234ABCD:presence-channel:100:{"some":"data"}') }
        its(:signature) { should eql('71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:auth) { should eql('somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:result) { should eql('auth' => 'somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855', 'data' => '{"some":"data"}') }
      end
    
    end
  
  end
  
end