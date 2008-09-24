require File.join(File.dirname(__FILE__), '/spec_helper')

require 'rubygems'
gem 'rspec'
require 'project_controller'

describe ProjectController, "when notified of a running build" do
  before do
    @controller = ProjectController.new
    @controller.stub!(:set_stage_submenu_enabled)
    @controller.stub!(:set_status_icon)
  end
  
  it "should set up a timer to fetch the deployment status"
  
  it "should set the status icon to running" do
  end
end