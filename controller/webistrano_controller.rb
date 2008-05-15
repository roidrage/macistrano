#
#  webistrano_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
gem 'hpricot'

class WebistranoController < OSX::NSObject
  ib_outlet :project_controller
  
  def fetch_projects(hosts)
    projects = []
    hosts.each do |host|
      projects << host.find_projects
    end
    projects.flatten
  end
end
