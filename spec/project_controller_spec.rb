require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project_controller'

describe ProjectController, "when notified of a running build" do
  before do
    @controller = ProjectController.new
    @controller.stub!(:set_stage_submenu_enabled)
    @controller.stub!(:set_status_icon)
    @webistrano_controller = stub(:webistrano)
    @webistrano_controller.stub!(:setup_deployment_status_timer)
    @controller.stub!(:webistrano_controller).and_return @webistrano_controller
  end
  
  it "should set up a timer to fetch the deployment status" do
    @controller.should_receive(:set_stage_submenu_enabled).with(anything, false, an_instance_of(String))
    @controller.build_running stub(:notification, :object => nil)
  end
  
  it "should set the status icon to running" do
    @controller.should_receive(:set_status_icon).with("success-building")
    @controller.build_running stub(:notification, :object => nil)
  end
  
  it "should set up the deployment status timer" do
    notification_object = stub(:notification_object)
    @webistrano_controller.should_receive(:setup_deployment_status_timer).with(notification_object)
    @controller.build_running stub(:notification, :object => notification_object)
  end
end