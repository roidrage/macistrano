#
#  post_load_operation.rb
#  macistrano
#
#  Created by Pom on 18.05.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class PostLoadOperation < LoadOperation
  include OSX
  attr_accessor :body
  
  def start
    encoded_body = NSString.stringWithString(body).dataUsingEncoding_allowLossyConversion(NSASCIIStringEncoding, true);
    
    request = NSMutableURLRequest.alloc.init
    request.setURL(@url)
    request.setHTTPMethod("POST")
    request.setValue_forHTTPHeaderField(encoded_body.length.to_s, "Content-Length")
    request.setValue_forHTTPHeaderField("text/xml", "Content-Type")
    request.setTimeoutInterval(15.0)
    
    request.setHTTPBody encoded_body
    
    @connection = NSURLConnection.connectionWithRequest_delegate(request, self)
    setExecuting true
  end
end
