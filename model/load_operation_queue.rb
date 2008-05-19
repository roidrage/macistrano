#
#  load_application_queue.rb
#  macistrano
#
#  Created by Pom on 17.05.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'load_operation'
require 'post_load_operation'

class LoadOperationQueue
  include OSX
  
  @@queue = NSOperationQueue.alloc.init
  @@queue.setMaxConcurrentOperationCount 5
  
  def self.queue_request(url, delegate, options = {})
    init_and_add_operation(LoadOperation, url, delegate, options)
  end
  
  def self.queue_post_request(url, delegate, options = {})
    init_and_add_operation(PostLoadOperation, url, delegate, options)
  end
  
  def self.init_and_add_operation(clazz, url, delegate, options = {})
    if url.is_a?(String)
      url = NSURL.URLWithString(url)
    end

    operation = clazz.alloc.initWithURL_delegate(url, delegate)
    operation.username = options[:username] if options[:username]
    operation.password = options[:password] if options[:password]
    operation.body = options[:body] if options[:body] && operation.respond_to?(:body)
    operation.on_success = options[:on_success] if options[:on_success]
    operation.on_error = options[:on_error] if options[:on_error]
    
    @@queue.addOperation operation
  end
  
  def self.queue
    @@queue
  end
  
  def self.items_in_queue
    @@queue.operations.size
  end
end
