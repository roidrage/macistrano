#
#  host.rb
#  macistrano
#
#  Created by Pom on 28.04.08.
#  Copyright (c) 2008 Paperplanes. All rights reserved.
#

require 'open-uri'
require 'rubygems'
require 'hpricot'

class Host
  attr_accessor :projects, :url, :username, :password
  
  def find_projects
    result = ""
    io = open("#{url}/projects.xml", :http_basic_authentication => [username, password])
    result = io.read
    to_projects result
  end
  
  def to_projects response
    projects = []
    doc = Hpricot.XML response
    (doc/'project').each do |data|
      project = Project.new
      project.id = (data/:id).text
      project.name = (data/:name).text
      project.fetch_stages
      projects << project
    end
    projects
  end
  
end
