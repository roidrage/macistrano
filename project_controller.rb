#
#  project_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
# require 'project'

class ProjectController < OSX::NSWindowController
   include OSX
   
   attr_reader :status_menu
   
   def awakeFromNib
     @webistrano_controller = WebistranoController.alloc.init
     @status_menu = OSX::NSMenu.alloc.init
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
   end
   
   def update_menu
     build_project_menu
     item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Quit", "quit:", "", 0)
     item.setTarget self
      
     @statusItem
   end
   
   def build_project_menu
     projects.each do |project|
       item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_(project.name, "quit:", "", 0)
       item.setTarget self
       add_stages item, project
     end
   end
   
   def add_stages item, project
     sub_menu = NSMenu.alloc.init
     
     project.stages.each do |stage|
       sub_item = sub_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(stage.name, "quit:", "", 0)
       sub_item.setTarget self
     end
     item.setSubmenu sub_menu
   end
   
   def projects
     project = Project.new
     project.name = "My Project"
     project.id = 1
     project.stages = stages
     [project]
   end
   
   def stages
     stage1 = Stage.new
     stage1.name = "test"
     
     stage2 = Stage.new
     stage2.name = "production"
     [stage1, stage2]
   end
end
