require File.join(File.dirname(__FILE__), '/spec_helper')

require 'deployment'
require 'host'
require 'project'
require 'stage'

describe Deployment, "when updating the deployment's data" do
  before do
    @deployment = Deployment.new
    @host = Host.new
    @host.url = "http://test.host"
    @host.password = "test"
    @host.username = "admin"
    @project = Project.new
    @project.webistrano_id = 1
    @project.host = @host
    @stage = Stage.new
    @stage.webistrano_id = 3
    @stage.project = @project
    @deployment.stage = @stage
    @deployment.webistrano_id = 4
  end
  
  it "should enqueue a request" do
    LoadOperationQueue.should_receive(:queue_request).with("http://test.host/projects/1/stages/3/deployments/4.xml", @deployment, :username => "admin", :password => "test", :on_success => :deployment_update_finished, :on_error => :deployment_update_failed)
    @deployment.update_data
  end
end

describe Deployment, "when notified of successful deployment check" do
  before do
    @deployment = Deployment.new
    @host = Host.new
    @host.url = "http://test.host"
    @project = Project.new
    @project.webistrano_id = 1
    @project.host = @host
    @stage = Stage.new
    @stage.webistrano_id = 3
    @stage.project = @project
    @deployment.stage = @stage
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
  
  it "should create a deployment from the xml data" do
    @stage.should_receive(:deployment_from_xml).with(@xml_data).and_return @deployment
    @deployment.deployment_update_finished @xml_data
  end
  
  it "should update its data from the xml-generated deployment" do
    new_deployment = Deployment.new
    new_deployment.log = "It's updated!"
    @stage.stub!(:deployment_from_xml).with(@xml_data).and_return new_deployment
    @deployment.deployment_update_finished @xml_data
    @deployment.log.should == "It's updated!"
  end
  
  it "should notify of the updated build status" do
    @stage.stub!(:deployment_from_xml).with(@xml_data).and_return @deployment
    @deployment.should_receive(:notify_deployment_status_updated).with(@deployment)
    @deployment.deployment_update_finished @xml_data
  end
end