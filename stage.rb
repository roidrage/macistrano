#
#  stage.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class Stage
  attr_accessor :id, :project, :name, :tasks
  
  def run_stage task
  end
  
  def read_xml path
    io = open("#{project.host.url}#{path}", :http_basic_authentication => [project.host.username, project.host.password])
    io.read
  end
  
  def fetch_tasks
    @tasks = []
    result = read_xml "/projects/#{project.id}/stages/#{id}/tasks.xml"
    doc = Hpricot.XML(result)
    (doc/'record').collect do |data|
      task = Task.new
      task.name = (data/:name).text
      task.description = (data/:description).text
      task.stage = self
      @tasks << task
    end
  end
end
