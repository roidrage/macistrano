#
#  stage.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'builder'
require 'notification_hub'
require 'task'

class Stage
  include NotificationHub
  
  attr_accessor :id, :project, :name, :tasks

  def deployments_url
    "#{project.host.url}/projects/#{project.id}/stages/#{self.id}/deployments.xml"
  end

  def tasks_url
    "#{project.host.url}/projects/#{project.id}/stages/#{id}/tasks.xml"
  end
  
  def run_stage task, comment
    LoadOperationQueue.queue_post_request(deployments_url, self, :username => project.host.username, :password => project.host.password, :body => new_deployment_as_xml(task, comment).to_s, :on_success => :post_url_finished, :on_error => :post_url_failed)
  end
  
  def post_url_finished(data)
    notify_deployment_started self
  end
  
  def post_url_failed(error)
    notify_starting_deployment_failed self
  end
  
  def new_deployment_as_xml task, comment
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.deployment do |xml|
      xml.task task
      xml.description comment
    end
    xml.target!
  end
  
  def fetch_tasks
    LoadOperationQueue.queue_request tasks_url, self, {:username => project.host.username, :password => project.host.password}
  end
  
  def url_finished(data)
    to_tasks(data)
    notify_tasks_loaded(self)
  end
  
  def to_tasks(result)
    @tasks ||= []
    doc = Hpricot.XML(result)
    (doc/'record').collect do |data|
      task = Task.new
      task.name = (data/:name).text
      task.description = (data/:description).text
      task.stage = self
      @tasks << task
    end
    @tasks
  end
end
