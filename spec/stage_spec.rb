require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project'
require 'stage'
require 'task'

describe Stage, "when generating urls" do
  before do
    @stage = Stage.new
    @stage.webistrano_id = 1
    @project = Project.new
    @project.webistrano_id = 2
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
    @stage.webistrano_id = 1
    
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

describe Stage, "when converting xml to a  deployment" do
  before do
    @stage = Stage.new
    @xml_data = <<END
<?xml version="1.0" encoding="UTF-8"?>
<deployment>
  <completed-at type="datetime">2008-05-18T19:31:00Z</completed-at>
  <created-at type="datetime">2008-05-18T19:30:58Z</created-at>
  <description>sdfd</description>
  <excluded-host-ids type="yaml">--- []

</excluded-host-ids>
  <id type="integer">9</id>
  <log>  * executing `deploy:start'
  * executing `webistrano:mongrel:start'
  * executing "sudo -p 'sudo password: ' -u user to run as with sudo mongrel_rails cluster::start -C PATH to mongrel_cluster.yml, you need to create it yourself --clean"
    servers: ["my.test.host"]
*** connection failed for: my.test.host (SocketError: getaddrinfo: nodename nor servname provided, or not known)
</log>
  <stage-id type="integer">4</stage-id>
  <success type="integer">0</success>
  <task>deploy:start</task>
  <updated-at type="datetime">2008-05-18T19:31:00Z</updated-at>
  <user-id type="integer">1</user-id>
</deployment>
END
  end
  
  it "should build a deployment object" do
    deployment = @stage.deployment_from_xml(@xml_data)
    deployment.should_not be_nil
  end
  
  it "should set the task name" do
    deployment = @stage.deployment_from_xml(@xml_data)
    deployment.task.should == "deploy:start"
  end
  
  it "should add the webistrano id" do
    deployment = @stage.deployment_from_xml(@xml_data)
    deployment.webistrano_id.should == "9"
  end
  
  it "should set completed_at" do
    deployment = @stage.deployment_from_xml(@xml_data)
    deployment.completed_at.should be_is_a(DateTime)
    deployment.completed_at.hour.should == 19
    deployment.completed_at.min.should == 31
    deployment.completed_at.day.should == 18
    deployment.completed_at.month.should == 5
    deployment.completed_at.year.should == 2008
  end

  it "should set created_at" do
    deployment = @stage.deployment_from_xml(@xml_data)
    deployment.created_at.should be_is_a(DateTime)
    deployment.created_at.hour.should == 19
    deployment.created_at.min.should == 30
    deployment.created_at.day.should == 18
    deployment.created_at.month.should == 5
    deployment.created_at.year.should == 2008
  end

  
end