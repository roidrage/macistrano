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
  
  def read_xml path
    io = open("#{url}#{path}", :http_basic_authentication => [username, password])
    io.read
  end
  
  def version_acceptable?
    response = read_xml '/sessions/version.xml'
    doc = Hpricot.XML response
    element = doc/'application'
    version = (element/:version).text if (element/:version).any?
    name = (element/:name).text if (element/:name).any?
    version.to_f >= 1.3 and name == 'Webistrano'
  end
  
  def find_projects
    result = ""
    result = read_xml "/projects.xml"
    to_projects result
  end
  
  def to_projects response
    projects = []
    doc = Hpricot.XML response
    (doc/'project').each do |data|
      project = Project.new
      project.id = (data/:id).text
      project.name = (data/:name).text
      project.host = self
      project.fetch_stages
      projects << project
    end
    projects
  end
  
end
