require File.join(File.dirname(__FILE__), '/spec_helper')

require 'rubygems'
gem 'rspec'
require 'host'
require 'project'
require 'stage'
require 'notification_hub'

describe Host, "when converting xml data to projects" do
  before do
    @host = Host.new
    @host.url = 'http://localhost:3000'
    @host.username = 'admin'
    @host.password = 'admin'
    
    @project = Project.new
    @project.stub!(:fetch_stages)
    Project.stub!(:new).and_return @project
    @projects_xml = <<XML
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
  end
  
  it "should convert the projects xml list to an array list" do
    projects = @host.to_projects(@projects_xml)
    projects.should have(1).items
  end
  
  it "should fetch the stages for a project" do
    @project.should_receive(:fetch_stages)
    @host.to_projects(@projects_xml)
  end
  
  it "should assign the name of a project" do
    projects = @host.to_projects(@projects_xml)
    projects.first.name.should == 'Other Project'
  end
  
  it "should assign the id of a project" do
    projects = @host.to_projects(@projects_xml)
    projects.first.id.should == "2"
  end
  
end

describe Host, "when finding projects" do
  before do
    @host = Host.new
    @host.url = 'http://localhost:3000'
    @host.username = 'admin'
    @host.password = 'admin'
    
  end
  
  it "should fetch the projects from the specified url" do
    LoadOperationQueue.should_receive(:queue_request).with(@host.collection_url, @host, :username => "admin", :password => "admin")
    @host.find_projects
  end
end

describe Host, "when checking the version" do
  before do
    @host = Host.new
    @host.url = 'http://localhost:3000'
    @host.username = 'admin'
    @host.password = 'admin'
    @valid_version_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<application>
  <name>Webistrano</name>
  <version>1.3.1</version>
</application>
XML
    @invalid_version_xml = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<application>
  <name>Webistrano</name>
  <version>1.2</version>
</application>
XML
    @murky_response = 'hello? anybody there?'
    @io = mock "io"
    @io.stub!(:read).and_return @valid_version_xml
    @host.stub!(:open).and_return @io
  end
  
  it "should accept the valid version" do
    @host.version_acceptable?(@valid_version_xml).should == true
  end
  
  it "should not accept an invalid version" do
    @host.version_acceptable?(@invalid_version_xml).should == false
  end
  
  it "should not accept the bogus output" do
    @host.version_acceptable?(@murky_response).should == false
  end
end

describe Host, "when building a version array" do
  before do
    @host = Host.new
  end
  
  it "should have three elements" do
    @host.to_version_array("1.3.1").should have(3).items
  end
  
  it "should have 1, 3, 1 as items" do
    @host.to_version_array("1.3.1").should == [1, 3, 1]
  end
end

describe Host, "version_eql_or_higher" do
  before do
    @host = Host.new
  end
  
  it "should accept 1.3.1" do
    @host.version_eql_or_higher([1, 3, 1]).should be_true
  end
  
  it "should not accept 1.2" do
    @host.version_eql_or_higher([1, 2]).should be_false
  end
  
  it "should accept 1.4" do
    @host.version_eql_or_higher([1, 4]).should be_true
  end
  
  it "should not accept 1.3" do
    @host.version_eql_or_higher([1, 3]).should be_false
  end
  
  it "should not accept 1" do
    @host.version_eql_or_higher([1]).should be_false
  end
end

describe Host, "when checking for the host version" do
  
end