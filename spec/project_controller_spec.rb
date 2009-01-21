require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project_controller'
require 'stage'
require 'host'
require 'project'
require 'webistrano_controller'

describe ProjectController, "when notified of a running build" do
  before do
    @controller = ProjectController.new
    @controller.stub!(:set_stage_submenu_enabled)
    @controller.stub!(:set_status_icon)
    @webistrano_controller = stub(:webistrano)
    @webistrano_controller.stub!(:setup_deployment_status_timer)
    @controller.stub!(:webistrano_controller).and_return @webistrano_controller
    @spinner = stub(:spinner, :startAnimation => true)
    @controller.instance_variable_set(:@deployment_status_spinner, @spinner)
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
  
  it "should activate the spinner" do
    notification_object = stub(:notification_object)
    @spinner.should_receive(:startAnimation).with(@controller)
    @controller.build_running stub(:notification, :object => notification_object)
  end
end

describe ProjectController, "when running a task" do
  before(:each) do
    @controller = ProjectController.alloc.init
    @task_field = stub(:task_field, :stringValue => "deploy", :setStringValue => "")
    @controller.instance_variable_set(:@taskField, @task_field)
    @description_field = stub(:description_field, :stringValue => "Chunky bacon", :setStringValue => "")
    @controller.instance_variable_set(:@descriptionField, @description_field)
    @stage = Stage.alloc.init
    @stage.stub!(:run_stage)
    @controller.instance_variable_set(:@selected_stage, @stage)
    @status_window_checkbox = stub(:show_status_window_checkbox, :state => "1")
    @controller.instance_variable_set(:@show_status_window_checkbox, @status_window_checkbox)
    @status_window = stub(:status_window, :makeKeyAndOrderFront => nil)
    @controller.instance_variable_set(:@statusHudWindow, @status_window)
    @run_task_dialog = stub(:run_task_dialog, :close => nil)
    @controller.instance_variable_set(:@runTaskDialog, @run_task_dialog)
    @status_window_text = stub(:status_window_text, :setStringValue => nil)
    @controller.instance_variable_set(:@statusHudWindowText, @status_window_text)
    @webistrano_controller = WebistranoController.alloc.init
    @controller.instance_variable_set(:@webistrano_controller, @webistrano_controller)
    @deployment_status_spinner = stub(:deployment_status_spinner, :startAnimation => nil)
    @controller.instance_variable_set(:@deployment_status_spinner, @deployment_status_spinner)
  end
  
  it "should run the selected stage" do
    @stage.should_receive(:run_stage).with("deploy", "Chunky bacon")
    @controller.runTask
  end
  
  it "should show the status window if box is checked" do
    @status_window.should_receive(:makeKeyAndOrderFront).with(@controller)
    @controller.runTask
  end
  
  it "should close the status window if box is not checked" do
    @status_window_checkbox.stub!(:state).and_return "0"
    @status_window.should_receive(:close)
    @controller.runTask
  end
  
  it "should close the run task dialog" do
    @run_task_dialog.should_receive(:close)
    @controller.runTask
  end
  
  it "should reset the text fields" do
    @task_field.should_receive(:setStringValue).with("")
    @description_field.should_receive(:setStringValue).with("")
    @controller.runTask
  end
  
  it "should notify of running build" do
    @webistrano_controller.should_receive(:setup_one_time_deployment_status_timer)
    @controller.runTask
  end
  
  it "should reset the status window" do
    @status_window_text.should_receive(:setStringValue).with("")
    @controller.runTask
  end
  
  it "should activate the progress indicator" do
    @deployment_status_spinner.should_receive(:startAnimation)
    @controller.runTask
  end
end

describe ProjectController, "when awaking from nib" do
  before(:each) do
    @controller = ProjectController.alloc.init
    @host = Host.new
    @preferences_controller = stub(:preferences, :hosts => [@host])
    @controller.instance_variable_set(:@preferences_controller, @preferences_controller)
    @status_window = stub(:status_window, :setFloatingPanel => true)
    @controller.instance_variable_set(:@statusHudWindow, @status_window)
  end
  
  it "should open the preference pane if no hosts are configured" do
    @preferences_controller.stub!(:hosts).and_return []
    @preferences_controller.should_receive(:showPreferences)
    @controller.awakeFromNib
  end
  
  it "should set the hosts in the webistrano controller" do
    @controller.awakeFromNib
    @controller.webistrano_controller.hosts.should == [@host]
  end
end

describe ProjectController, "when notified of a completed build" do
  before(:each) do
    @controller = ProjectController.alloc.init
    @spinner = stub(:spinner, :stopAnimation => true)
    @controller.instance_variable_set(:@deployment_status_spinner, @spinner)
    @controller.stub!(:set_stage_submenu_enabled)
    @controller.stub!(:set_status_icon)
    @deployment = Deployment.alloc.init
    @webistrano_controller = WebistranoController.alloc.init
    @controller.instance_variable_set(:@webistrano_controller, @webistrano_controller)
  end
  
  it "should stop the spinner animation" do
    @spinner.should_receive(:stopAnimation).with(@controller)
    @controller.build_completed(stub(:notification, :object => @deployment))
  end
  
  it "should stop the deployment update timer" do
    @webistrano_controller.should_receive(:remove_deployment_timer)
    @controller.build_completed(stub(:notification, :object => @deployment)) 
  end
end