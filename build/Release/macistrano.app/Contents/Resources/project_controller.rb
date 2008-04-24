#
#  project_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class ProjectController < OSX::NSWindowController
   include OSX
   
   attr_reader :status_menu
   
   def awakeFromNib
     @webistrano_controller = WebistranoController.alloc.init
     puts "here"
     @status_menu = OSX::NSMenu.alloc.init
     puts "there"
     create_status_bar
     
   end
   
   ib_outlet :text_field
   
   ib_action :fire_event
   
   def fire_event
      @webistrano_controller.fetch_projects
   end
   
   def quit(sender)
      NSApp.stop(nil)
   end
   
   def build_menu
   end
   
   def create_status_bar
   	@statusItem = OSX::NSStatusBar.systemStatusBar.statusItemWithLength(OSX::NSVariableStatusItemLength)
      path = NSBundle.mainBundle.pathForResource_ofType("icon-failure", "png")
		
      initial_icon = OSX::NSURL.fileURLWithPath("Resources/icon-failure.png")
      @statusItem.setImage NSImage.alloc.initByReferencingFile(path)
      @statusItem.setHighlightMode true
      @statusItem.setMenu status_menu
      @statusItem.setTarget self
      update_menu
      return @statusItem
   end
   
   def update_menu
      item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Quit", "quit:", "", 0)
      item.setTarget self
   end
end
