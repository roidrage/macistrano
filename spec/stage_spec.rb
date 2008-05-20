require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project'
require 'stage'
require 'task'

describe Stage, "when generating urls" do
  before do
    @stage = Stage.new
    @stage.id = 1
    @project = Project.new
    @project.id = 2
    @stage.project = @project
    @host = Host.new
    @host.url = "http://webistrano.de"
    @project.host = @host
  end
  
  it "should have a deployments_url" do
    @stage.deployments_url.should == "http://webistrano.de/projects/2/stages/1/deployments.xml"
  end
  
  it "should have a tasks_url" do
    @stage.tasks_url.should == "http://webistrano.de/projects/2/stages/1/tasks.xml"
  end
end

describe Stage, "when converting tasks from xml" do
  before do
    @stage = Stage.new
    @stage.id = 1
    
    @tasks_xml =<<END
    <?xml version="1.0" encoding="UTF-8"?>
    <records type="array">
      <record>
        <name>webistrano:mongrel:start</name>
        <description>Start mongrel</description>
      </record>
      <record>
        <name>webistrano:mongrel:restart</name>
        <description>Restart mongrel</description>
      </record>
      <record>
        <name>webistrano:mongrel:stop</name>
        <description>Stop mongrel</description>
      </record>
    </records>
END
  end
  
  it "should find three tasks" do
    @stage.to_tasks(@tasks_xml).should have(3).items
  end
  
  it "should ignore borked data" do
    @stage.to_tasks("some stuff").should have(0).items
  end
  
  it "should assign itself as the task's stage" do
    @stage.to_tasks(@tasks_xml).first.stage.should == @stage
  end
end

describe Stage, "after fetching tasks" do
  before do
    @tasks = []
    @stage = Stage.new
    @stage.stub!(:to_tasks).and_return @tasks
  end
  
  it "should notify that it's done" do
    @stage.should_receive(:notify_tasks_loaded)
    @stage.url_finished("some data")
  end
  
  it "should mark itself as fully loaded" do
    @stage.url_finished("some data")
    @stage.fully_loaded?.should == true
  end
end