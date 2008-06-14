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
require 'deployment'
require 'date'

class Stage < OSX::NSObject
  include NotificationHub
  
  notify :check_for_running_build, :when => :check_for_running_builds
  attr_accessor :webistrano_id, :project, :name, :tasks, :fully_loaded
  
  def fully_loaded?
    fully_loaded
  end
  
  def deployments_url
    "#{project.host.url}/projects/#{project.webistrano_id}/stages/#{self.webistrano_id}/deployments.xml"
  end

  def tasks_url
    "#{project.host.url}/projects/#{project.webistrano_id}/stages/#{webistrano_id}/tasks.xml"
  end
  
  def latest_deployment_url
    "#{project.host.url}/projects/#{project.webistrano_id}/stages/#{webistrano_id}/deployments/latest.xml"
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
    self.fully_loaded = true
    notify_tasks_loaded(self)
    notify_stage_tasks_loaded(self)
  end
  
  def to_tasks(result)
    @tasks ||= []
    doc = Hpricot.XML(result)
    (doc/'record').collect do |data|
      task = Task.alloc.init
      task.name = (data/:name).text
      task.description = (data/:description).text
      task.stage = self
      @tasks << task
    end
    @tasks
  end
  
  def check_for_running_build
    return if build_check_running?
    LoadOperationQueue.queue_request latest_deployment_url, self, {:username => project.host.username, :password => project.host.password, :on_success => :check_for_running_build_successful, :on_error => :check_for_running_build_failed}
    build_check_running!
  end
  
  def check_for_running_build_successful(data)
    deployment = deployment_from_xml(data)
  end
  
  def check_for_running_build_failed(url, error)
  end
  
  def deployment_from_xml(data)
    doc = Hpricot.XML(data)
    deployment = Deployment.alloc.init
    (doc/'deployment').collect do |deployment_data|
      deployment.webistrano_id = (deployment_data/:id).text
      deployment.task = (deployment_data/:task).text
      deployment.completed_at = DateTime.parse((deployment_data/:"completed-at").text)
      deployment.created_at = DateTime.parse((deployment_data/:"created-at").text)
    end
    deployment
  end
  
  def build_check_running!
    @build_check_running = true
  end
  
  def build_check_running?
    @build_check_running
  end
end
