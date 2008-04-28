#
#  webistrano_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'

class WebistranoController < OSX::NSObject
  ib_outlet :project_controller
  
  def fetch_projects
    host = Host.new
    host.url = "http://localhost:3000"
    host.username = 'admin'
    host.password = 'admin'
    host.find_projects
  end
  
  def projects
    project = Project.new
    project.name = "My Project"
    project.id = 1
    project.stages = stages project
    [project]
  end
  
  def stages project
    stage1 = Stage.new
    stage1.name = "test"
    stage1.project = project
    
    stage2 = Stage.new
    stage2.name = "production"
    stage2.project = project
    [stage1, stage2]
  end

end
