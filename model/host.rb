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
require 'load_operation_queue'

class Host < OSX::NSObject
  include NotificationHub
  notify :project_loaded, :when => :project_fully_loaded
  
  ACCEPT_VERSION = [1, 3, 1]
  
  attr_accessor :projects, :url, :username, :password
  
  def read_xml path
    io = open("#{url}#{path}", :http_basic_authentication => [username, password])
    io.read
  end
  
  def version_url
    "#{url}/sessions/version.xml"
  end
  
  def schedule_version_check
    LoadOperationQueue.queue_request(version_url, self, :username => username, :password => :password, :on_success => :version_check_finished, :on_error => :version_check_failed)
  end
  
  def fully_loaded?
    @projects && @projects.select{|project| !project.fully_loaded?}.empty?
  end
  
  def project_loaded(notification)
    return unless notification.object.host == self
    notify_host_fully_loaded(self) if fully_loaded?
  end
  
  def load_url_failed(url, error)
  end
  
  def version_check_finished(data)
    if version_acceptable?(data)
      notify_host_version_acceptable self
    else
      notify_host_version_inacceptable self
    end
  end
  
  def version_check_failed(error)
    puts error.inspect
  end
  
  def version_acceptable?(response)
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
    to_projects(data)
    notify_project_loaded :host => self, :projects => projects
  end
  
  def to_projects response
    @projects = []
    doc = Hpricot.XML response
    (doc/'project').each do |data|
      project = Project.new
      project.id = (data/:id).text
      project.name = (data/:name).text
      project.host = self
      @projects << project
      project.fetch_stages
    end
  end
  
end
