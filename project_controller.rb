#
#  project_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'

class ProjectController < OSX::NSWindowController
   include OSX
   
   attr_reader :status_menu
   attr_accessor :loaded
   
   def awakeFromNib
     @webistrano_controller = WebistranoController.alloc.init
     @status_menu = OSX::NSMenu.alloc.init
     @preferences_controller = PreferencesController.alloc.init
     
     create_status_bar
   end
   
   
   ib_action :fire_event
   
   def fire_event
   end
   
   def quit(sender)
      NSApp.stop(nil)
   end

   def show_preferences(sender)
     @preferences_controller.showPreferences
   end
   
   def clicked(sender)
     puts sender.representedObject.name
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

     item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Preferences", "show_preferences:", "", 1)
     item.setTarget self
      
     @statusItem
   end
   
   def build_project_menu
     lastIndex = 0
     @webistrano_controller.fetch_projects.each do |project|
       item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_(project.name.to_s, "clicked:", "", lastIndex)
       item.setTarget self
       lastIndex += 1
       add_stages item, project
     end
   end
   
   def add_stages item, project
     sub_menu = NSMenu.alloc.init
     lastIndex = 0
     project.stages.each do |stage|
       sub_item = sub_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(stage.name, "clicked:", "", lastIndex)
       sub_item.setTarget self
       sub_item.setRepresentedObject stage
       lastIndex += 1
     end
     item.setSubmenu sub_menu
   end
end
