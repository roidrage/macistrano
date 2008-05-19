require File.join(File.dirname(__FILE__), '/spec_helper')
require 'rubygems'
gem 'rspec'
require 'project'

describe Project, "when fetching stages" do
  before do
    @project = Project.new
    @host = Host.new
    @host.url = 'http://localhost:3000'
    @host.username = 'admin'
    @host.password = 'admin'
    @project.host = @host
  end

  it "should queue the request" do
    LoadOperationQueue.should_receive(:queue_request)
    @project.fetch_stages
  end
end