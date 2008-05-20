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
  
  it "should not notify if stages were found" do
    @project.should_not_receive(:notify_project_fully_loaded)
    @project.to_stages(@stages_xml)
  end
  
  it "should notify that the project was fully loaded when there are no stages in it" do
    @project.should_receive(:notify_project_fully_loaded)
    @project.to_stages("")
  end
end

describe Project, "when being notified of a stage being loaded" do
  before do
    @project = Project.new
    @stage1 = Stage.new
    @stage2 = Stage.new
    @project.stages = [@stage1, @stage2]
  end
  
  it "should notify that all its stages were loaded when all are fully loaded" do
    @stage2.fully_loaded = true
    @stage1.fully_loaded = true
    @project.should_receive(:notify_project_fully_loaded)
    @project.stage_loaded(stub("notification", :object => @stage1))
  end
  
  it "should not notify that all its stages were loaded when not all are fully loaded" do
    @stage2.fully_loaded = true
    @stage1.fully_loaded = false
    @project.should_not_receive(:notify_project_fully_loaded)
    @project.stage_loaded(stub("notification", :object => @stage1))
  end
end