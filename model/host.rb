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
require 'notification_hub'

class Host
  include NotificationHub
  
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
    version_eql_or_higher(to_version_array(version)) and name == 'Webistrano'
  end
  
  def version_eql_or_higher version
    return false if version.nil? || version.size == 0
    version[1] = 0 if version.size == 1
    version[2] = 0 if version.size == 2
    if version[0] > ACCEPT_VERSION[0]
      true
    elsif version[0] >= ACCEPT_VERSION[0] and version[1] > ACCEPT_VERSION[1]
      true
    elsif version[0] >= ACCEPT_VERSION[0] and version[1] == ACCEPT_VERSION[1] and version[2] >= ACCEPT_VERSION[2]
      true
    else
      false
    end
    
  end
  
  def to_version_array(version)
    unless version == nil || version == ""
      version_parts = version.split(/\./)
      version_parts.each_with_index {|num, index| version_parts[index] = num.to_i}
      version_parts
    end
  end
  
  def collection_url
    "#{url}/projects.xml"
  end
  
  def find_projects
    LoadOperationQueue.queue_request collection_url, self, {:username => username, :password => password}
  end
  
  def url_finished(data)
    projects = to_projects(data)
    notify_project_loaded :host => self, :projects => projects
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
