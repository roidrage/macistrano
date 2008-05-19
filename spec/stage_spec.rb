require File.join(File.dirname(__FILE__), '/spec_helper')

require 'project'
require 'stage'

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