#
#  webistrano_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class WebistranoController < OSX::NSObject
  ib_outlet :project_controller
  
  def fetch_projects
    projects
  end
  def projects
    project = Project.new
    project.name = "My Project"
    project.id = 1
    project.stages = stages
    [project]
  end
  
  def stages
    stage1 = Stage.new
    stage1.name = "test"
    
    stage2 = Stage.new
    stage2.name = "production"
    [stage1, stage2]
  end

end
