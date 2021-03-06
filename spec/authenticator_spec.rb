require 'spec_helper'

describe Socky::Authenticator do
  
  # Set authenticator secret
  before { Socky::Authenticator.secret = 'application_secret_key' }
  
  it "should raise exception on invalid data" do
    lambda { Socky::Authenticator.new("invalid") }.should raise_error ArgumentError, "Expected hash or JSON"
  end
  
  it "should allow passing Hash" do
    subject = Socky::Authenticator.new('some' => 'data')
    subject.instance_variable_get('@params').should eql('some' => 'data')
  end
  
  it "should allow passing JSON-encoded Hash" do
    subject = Socky::Authenticator.new('{"some":"data"}')
    subject.instance_variable_get('@params').should eql('some' => 'data')
  end
  
  it "should raise on JSON-encoded non-Hash" do
    lambda { Socky::Authenticator.new('["some","data"]') }.should raise_error ArgumentError, "Expected hash or JSON"
  end
  
  context "instance" do
    let(:default_params) { {:connection_id => '1234ABCD', :channel => 'some_channel'} }
    subject { Socky::Authenticator.new(default_params) }
    # Set salt to constant to make tests non-random
    before { subject.salt =  'somerandomstring' }
  
    its(:salt) { should eql('somerandomstring') }
    its(:connection_id) { should eql('1234ABCD') }
    its(:channel) { should eql('some_channel') }
    its(:rights) { should eql(:read => true, :write => false, :hide => false) }
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
      subject = Socky::Authenticator.new(default_params.reject{|k,v| k == :connection_id})
      subject.connection_id.should be_nil
      lambda { subject.result }.should raise_error ArgumentError, 'expected connection_id'
    end
  
    it "should raise if channel is nil" do
      subject = Socky::Authenticator.new(default_params.reject{|k,v| k == :channel})
      subject.channel.should be_nil
      lambda { subject.result }.should raise_error ArgumentError, 'expected channel'
    end
  
    it "should not allow to changing rights at default" do
      subject = Socky::Authenticator.new(default_params.merge(:read => false, :write => true, :hide => true))
      subject.rights.should eql(:read => true, :write => false, :hide => false)
    end
  
    context "with changing rights enables" do
      it "should allow changing 'read' to false" do
        subject = Socky::Authenticator.new(default_params.merge(:read => false), :allow_changing_rights => true)
        subject.rights[:read].should eql(false)
      end
    
      it "should allow changing 'write' to true" do
        subject = Socky::Authenticator.new(default_params.merge(:write => true), :allow_changing_rights => true)
        subject.rights[:write].should eql(true)
      end
    
      it "should not allow changing 'hide' to true" do
        subject = Socky::Authenticator.new(default_params.merge(:hide => true), :allow_changing_rights => true)
        subject.rights[:hide].should eql(false)
      end
    
    end
  
    context "presence channel" do
      subject { Socky::Authenticator.new(default_params.merge(:channel => 'presence-channel')) }
    
      its(:channel) { should eql('presence-channel') }
      its(:rights) { should eql(:read => true, :write => false, :hide => false) }
      its(:presence?) { should eql(true) }
      its(:user_data) { should eql(nil) }
      its(:string_to_sign) { should eql('somerandomstring:1234ABCD:presence-channel:100') }
      its(:signature) { should eql('f0332936d0c3e59e2d9840d0c0b538ad88fba467ba546d8f9f91bc8d3cd95a1c') }
      its(:auth) { should eql('somerandomstring:f0332936d0c3e59e2d9840d0c0b538ad88fba467ba546d8f9f91bc8d3cd95a1c') }
      its(:result) { should eql('auth' => 'somerandomstring:f0332936d0c3e59e2d9840d0c0b538ad88fba467ba546d8f9f91bc8d3cd95a1c') }
    
      context "with hash user data provided" do
        subject { Socky::Authenticator.new(default_params.merge(:channel => 'presence-channel', 'data' => { 'some' => 'data' })) }
      
        its(:user_data) { should eql('{"some":"data"}') }
        its(:string_to_sign) { should eql('somerandomstring:1234ABCD:presence-channel:100:{"some":"data"}') }
        its(:signature) { should eql('71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:auth) { should eql('somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:result) { should eql('auth' => 'somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855', 'data' => '{"some":"data"}') }
      end
      
      context "with string user data provided" do
        subject { Socky::Authenticator.new(default_params.merge(:channel => 'presence-channel', 'data' => '{"some":"data"}')) }
      
        its(:user_data) { should eql('{"some":"data"}') }
        its(:string_to_sign) { should eql('somerandomstring:1234ABCD:presence-channel:100:{"some":"data"}') }
        its(:signature) { should eql('71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:auth) { should eql('somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855') }
        its(:result) { should eql('auth' => 'somerandomstring:71dabae0f47da5ac8e4982fa062abf09788f8fab40b7634427e380bfcec29855', 'data' => '{"some":"data"}') }
      end
    
    end
  
  end
  
end