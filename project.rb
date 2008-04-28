#
#  project.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class Project
  
  attr_accessor :name, :id, :stages
  
  def fetch_stages
    result = ""
    open("http://localhost:3000/projects/#{self.id}/stages.xml", :http_basic_authentication => ['admin', 'admin']) {|f| f.each_line {|line| result << line}}
    self.stages = to_stages result
  end

  def to_stages response
    stages = []
    doc = XmlSimple.xml_in response
    doc['stage'].each do |data|
      stage = Stage.new
      stage.id = data['id'][0]['content']
      stage.name = data['name'][0]
      stages << stage
    end
    stages
  end
end
