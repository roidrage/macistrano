require 'keychain'
require 'host'

describe Keychain do
  before do
    @host = Host.new
    @host.url = "www.host.url"
    @host.username = 'horst'
    @host.password = 'password'
    Keychain.remove_password(@host)
  end
  
  it "should add a password" do
    Keychain.add_password(@host).should == true
  end
  
  it "should find the password" do
    Keychain.add_password(@host)
    @host.password = nil
    Keychain.find_password(@host)
    @host.password.should == "password"
  end
  
  it "should delete the password" do
    Keychain.add_password(@host)
    Keychain.remove_password(@host).should == true
  end
end