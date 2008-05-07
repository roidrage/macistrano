require 'rubygems'
gem 'rspec'
require 'host'
require 'project'
require 'stage'

describe Host do
  before do
    @host = Host.new
    @host.url = 'http://localhost:3000'
    @host.username = 'admin'
    @host.password = 'admin'
    
    @io = mock "io"
    @io.stub!(:read).and_return ''
    @host.stub!(:open).and_return @io
    @project = Project.new
    @project.stub!(:fetch_stages)
    Project.stub!(:new).and_return @project
  end
  
  it "should fetch the projects from the specified url" do
    @host.should_receive(:open) do |url, options|
      url.should == 'http://localhost:3000/projects.xml'
      @io
    end
    
    @host.find_projects
  end
  
  it "should use user and password for authentication" do
    @host.should_receive(:open) do |url, options|
      options[:http_basic_authentication].should == ['admin', 'admin']
      @io
    end
    
    @host.find_projects
  end
  
  it "should convert the projects xml list to an array list" do
    projects_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<projects type="array">
  <project>
    <created-at type="datetime">2008-04-28T19:38:51Z</created-at>
    <description>sfadf</description>
    <id type="integer">2</id>
    <name>Other Project</name>
    <template>mongrel_rails</template>
    <updated-at type="datetime">2008-04-28T19:38:51Z</updated-at>
  </project>
</projects>
XML
    @io.stub!(:read).and_return projects_xml
    @host.stub!(:open).and_return @io
    projects = @host.find_projects
    projects.should have(1).items
  end
end