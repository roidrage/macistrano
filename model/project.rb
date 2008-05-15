#
#  project.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'hpricot'

class Project
  
  attr_accessor :name, :id, :stages, :host

  def read_xml path
    io = open("#{host.url}#{path}", :http_basic_authentication => [host.username, host.password])
    io.read
  end
  
  def fetch_stages
    result = read_xml "/projects/#{self.id}/stages.xml"
    self.stages = to_stages result
  end

  private
  
  def to_stages response
    stages = []

    doc = Hpricot.XML response
    (doc/'stage').each do |data|
      stage = Stage.new
      stage.id = (data/:id).text
      stage.name = (data/:name).text
      stage.project = self
      stage.fetch_tasks
      stages << stage
    end
    stages
  end
end
