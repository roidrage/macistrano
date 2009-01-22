#
#  rb_main.rb
#  macistrano
#
#  Created by Pom on 22.04.08.
#  Copyright (c) 2008, 2009 Mathias Meyer. All rights reserved.
#

if defined?(COCOA_APP_RESOURCES_DIR)
  $LOAD_PATH << File.join(File.dirname(COCOA_APP_RESOURCES_DIR),"Frameworks","RubyCocoa.framework", "Resources", "ruby")
end

require 'osx/cocoa'

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
