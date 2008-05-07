require 'rubygems'
gem 'rspec'
require 'webistrano_controller'
require 'host'

describe WebistranoController do
  before do
    @controller = WebistranoController.new
    @host = Host.new
    @host.stub!(:find_projects)
    Host.stub!(:new).and_return @host
  end
  
  it "should fetch new projects for a host" do
    @host.should_receive(:find_projects)
    @controller.fetch_projects
  end
end