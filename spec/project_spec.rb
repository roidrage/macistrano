require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project'
require 'stage'

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

describe Project, "when converting stages from xml" do
  
  before do
    @project = Project.new
    @project.stub!(:fetch_tasks)
    
    @stage = Stage.new
    @stage.stub!(:fetch_tasks)
    Stage.stub!(:new).and_return @stage
    
    @stages_xml = <<END
    <?xml version="1.0" encoding="UTF-8"?>
    <stages type="array">
      <stage>
        <alert-emails></alert-emails>
        <created-at type="datetime">2008-04-28T18:44:35Z</created-at>
        <id type="integer">1</id>
        <name>development</name>
        <project-id type="integer">1</project-id>
        <updated-at type="datetime">2008-04-28T18:44:35Z</updated-at>
      </stage>
      <stage>
        <alert-emails></alert-emails>
        <created-at type="datetime">2008-04-28T18:45:13Z</created-at>
        <id type="integer">2</id>
        <name>production</name>
        <project-id type="integer">1</project-id>
        <updated-at type="datetime">2008-04-28T18:45:13Z</updated-at>
      </stage>
      <stage>
        <alert-emails></alert-emails>
        <created-at type="datetime">2008-04-28T18:45:20Z</created-at>
        <id type="integer">3</id>
        <name>test</name>
        <project-id type="integer">1</project-id>
        <updated-at type="datetime">2008-04-28T18:45:20Z</updated-at>
      </stage>
    </stages>
END
  end
  
  it "should find three stages" do
    stages = @project.to_stages(@stages_xml)
    stages.should have(3).items
  end
  
  it "should fetch the tasks for the stages" do
    @stage.should_receive(:fetch_tasks).at_least(:once)
    @project.to_stages(@stages_xml)
  end
end