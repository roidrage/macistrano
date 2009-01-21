require 'osx/cocoa'
require 'notification_hub'

class Deployment < OSX::NSObject
  include NotificationHub
  attr_accessor :webistrano_id, :task, :created_at, :completed_at, :success, :stage, :log, :status
  
  def deployment_url
    "#{stage.project.host.url}/projects/#{stage.project.webistrano_id}/stages/#{stage.webistrano_id}/deployments/#{webistrano_id}.xml"
  end
  
  def update_data
    LoadOperationQueue.queue_request(deployment_url, self, :username => stage.project.host.username, :password => stage.project.host.password, :on_success => :deployment_update_finished, :on_error => :deployment_update_failed)
  end
  
  def deployment_update_failed(data, error)
  end
  
  def deployment_update_finished(data)
    deployment = stage.deployment_from_xml(data)
    self.completed_at = deployment.completed_at
    self.log = deployment.log
    self.success = deployment.success
    notify_deployment_status_updated self
  end
end