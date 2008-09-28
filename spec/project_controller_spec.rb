require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project_controller'

describe ProjectController, "when notified of a running build" do
  before do
    @controller = ProjectController.new
    @controller.stub!(:set_stage_submenu_enabled)
    @controller.stub!(:set_status_icon)
  end
  
  it "should set up a timer to fetch the deployment status" do
    @controller.should_receive(:set_stage_submenu_enabled).with(anything, false, an_instance_of(String))
    @controller.build_running stub(:notification, :object => nil)
  end
  
  it "should set the status icon to running" do
    @controller.should_receive(:set_status_icon).with("success-building")
    @controller.build_running stub(:notification, :object => nil)
  end
end