#
#  project.rb
#  macistrano
#
#  Created by Pom on 25.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'hpricot'
require 'notification_hub'
require 'host'

class Project < OSX::NSObject
  include NotificationHub
  notify :stage_loaded, :when => :stage_tasks_loaded
  
  attr_accessor :name, :webistrano_id, :stages, :host
  
  def fully_loaded?
    @stages && @stages.select{|stage| !stage.fully_loaded?}.empty?
  end

  def stages_url
    "#{host.url}/projects/#{self.webistrano_id}/stages.xml"
  end
  
  def fetch_stages
    LoadOperationQueue.queue_request stages_url, self, {:username => host.username, :password => host.password}
  end

  def url_finished(data)
    self.stages = to_stages data
    notify_stages_loaded self
  end
  
  def stage_loaded(notification)
    return unless notification.object.project == self
    notify_project_fully_loaded(self) if fully_loaded?
  end
  
  def to_stages response
    @stages = []

    doc = Hpricot.XML response
    (doc/'stage').each do |data|
      stage = Stage.alloc.init
      stage.webistrano_id = (data/:id).text
      stage.name = (data/:name).text
      stage.project = self
      @stages << stage
      stage.fetch_tasks
    end
    notify_project_fully_loaded(self) if @stages.empty?
    @stages
  end
end
