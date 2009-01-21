#
#  webistrano_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'notification_hub'

class WebistranoController < OSX::NSObject
  include NotificationHub
  attr_accessor :hosts, :deployment_timers

  notify :host_loaded, :when => :host_fully_loaded
  notify :host_loaded, :when => :host_load_failed
  notify :remove_host, :when => :host_removed
  notify :remove_deployment_timer, :when => :deployment_status_updated

  def setup_build_check_timer
    @build_status_timer = OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(30.0, self, :check_for_running_builds, nil, true)
    @build_status_timer.fire
  end
  
  def deployment_timers
    @deployment_timers ||= {}
  end
  
  def setup_deployment_status_timer(deployment)
    unless deployment_timers[deployment.webistrano_id]
      deployment_timers[deployment.webistrano_id] = OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(5.0, deployment, :update_data, nil, true)
    end
  end

  def remove_deployment_timer(notification)
    deployment_timers[notification.object.webistrano_id] = nil
  end
  
  def setup_one_time_deployment_status_timer
    OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(10.0, self, :check_for_running_builds, nil, false)
  end
  
  def check_for_running_builds
    notify_check_for_running_builds nil
  end

  def host_loaded(notification)
    return unless @hosts
    notify_all_hosts_loaded if @hosts.select{|host| !host.fully_loaded?}.empty?
  end
  
  def remove_host(notification)
    host = notification.object
    @hosts.delete(host) if @hosts
  end
end
