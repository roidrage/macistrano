require File.join(File.dirname(__FILE__), '/spec_helper')

require 'rubygems'
gem 'rspec'
require 'webistrano_controller'
require 'host'

describe WebistranoController do
  before do
    @controller = WebistranoController.new
    @host = Host.new
    class Host < OSX::NSObject
      attr_accessor :projects_fetched
      def find_projects
        @projects_fetched = true
      end
    end
  end
  
  it "should fetch new projects for a host" do
    @controller.fetch_projects([@host])
    @host.projects_fetched.should be_true
  end
end