require File.join(File.dirname(__FILE__), '/spec_helper')

require 'rubygems'
gem 'rspec'
require 'webistrano_controller'
require 'host'

describe WebistranoController, "when notified of loaded hosts" do
  before do
    @controller = WebistranoController.new
    @host = Host.new
  end

  it "should notify of all hosts being loaded when all hosts are loaded" do
    @host.stub!(:fully_loaded?).and_return true
    @controller.hosts = [@host]
    @controller.should_receive(:notify_all_hosts_loaded)
    @controller.host_loaded(stub("notification", :object => @host))
  end
  
  it "should not notify of all hosts being loaded when one isn't loaded" do
    @host.stub!(:fully_loaded?).and_return false
    @controller.hosts = [@host]
    @controller.should_not_receive(:notify_all_hosts_loaded)
    @controller.host_loaded(stub("notification", :object => @host))
  end
end

describe WebistranoController, "when notified of removed hosts" do
  before do
    @controller = WebistranoController.new
    @host = Host.new
    @controller.hosts = [@host]
  end
  
  it "should remove the host from the list" do
    @controller.remove_host(stub(:notification, :object => @host))
    @controller.hosts.should == []
  end
  
  it "should do nothing then the host list is nil" do
    @controller.hosts = nil
    @controller.remove_host(stub(:notification, :object => @host))
    @controller.hosts.should == nil
  end
  
end