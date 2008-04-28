#
#  host.rb
#  macistrano
#
#  Created by Pom on 28.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'open-uri'
require 'rubygems'
gem 'xml-simple'
require 'xmlsimple'

class Host
  attr_accessor :projects, :url, :username, :password
  
  def find_projects
    result = ""
    open('http://localhost:3000/projects.xml', :http_basic_authentication => ['admin', 'admin']) {|f| f.each_line {|line| result << line}}
    to_projects result
  end
  
  def to_projects response
    projects = []
    doc = XmlSimple.xml_in response
    doc['project'].each do |data|
      project = Project.new
      project.id = data['id'][0]['content']
      project.name = data['name'][0]
      project.fetch_stages
      projects << project
    end
    projects
  end
  
end
