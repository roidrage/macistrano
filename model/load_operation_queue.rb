#
#  load_application_queue.rb
#  macistrano
#
#  Created by Pom on 17.05.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class LoadOperationQueue
  include OSX
  
  @@queue = NSOperationQueue.alloc.init
  @@queue.setMaxConcurrentOperationCount 5
  
  def self.queue_request(url, delegate, options = {})
    if url.is_a?(String)
      url = NSURL.URLWithString(url)
    end
    
    operation = LoadOperation.alloc.initWithURL_delegate(url, delegate)
    operation.username = options[:username] if options[:username]
    operation.password = options[:password] if options[:password]
    
    @@queue.addOperation operation
  end
  
  def self.queue_post_request(url, delegate)
  end
  
  def self.queue
    @@queue
  end
  
  def self.items_in_queue
    @@queue.operations.size
  end
end
