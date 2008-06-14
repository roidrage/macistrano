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
  attr_accessor :hosts

  notify :host_loaded, :when => :host_fully_loaded
  notify :remove_host, :when => :host_removed

  def setup_build_check_timer
    @loading_timer = OSX::NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(30.0, self, :check_for_running_builds, nil, true)
  end
  
  def check_for_running_builds
    notify_check_for_running_builds
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
