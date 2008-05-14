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
  ACCEPT_VERSION = [1, 3, 1]
  
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
    version = to_version_array(version)
    version_eql_or_higher  and name == 'Webistrano'
  end
  
  def version_eql_or_higher version
    ACCEPT_VERSION.each do |part|
    end
  end
  
  def to_version_array(version)
    if version == nil || version == ""
      version_parts = version.split(/\./)
      version_parts.each_with_index {|num, index| version_parts[index] = num.to_i}
      version_parts
    end
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
