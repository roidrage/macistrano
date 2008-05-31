#
#  task.rb
#  macistrano
#
#  Created by Pom on 12.05.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class Task < OSX::NSObject
  attr_accessor :stage, :name, :description
end
