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

  def host_loaded(notification)
    return unless @hosts
    notify_all_hosts_loaded if @hosts.select{|host| !host.fully_loaded?}.empty?
  end
  
  def remove_host(notification)
    host = notification.object
    @hosts.delete(host) if @hosts
  end
end
