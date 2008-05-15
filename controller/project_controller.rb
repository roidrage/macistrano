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
   
   ib_outlet :runTaskDialog
   ib_outlet :taskField
   ib_outlet :descriptionField
   
   def awakeFromNib
     @webistrano_controller = WebistranoController.alloc.init
     @status_menu = OSX::NSMenu.alloc.init
     @preferences_controller = PreferencesController.alloc.init
     registerObservers
     create_status_bar
   end
   
   def registerObservers
     NSNotificationCenter.defaultCenter.addObserver_selector_name_object self, "updateHostList:", "HostListUpdated", nil
   end
   
   def updateHostList(notification)
     @statusItem.menu.release
     @statusItem.setMenu nil
     @status_menu = OSX::NSMenu.alloc.init
     @statusItem.setMenu @status_menu
     update_menu notification.object
   end
   
   def quit(sender)
      NSApp.stop(nil)
   end

   def show_preferences(sender)
     @preferences_controller.showPreferences
   end
   
   def clicked(sender)
     @runStage = sender.representedObject.stage
     @taskField.setStringValue sender.representedObject.name
     NSApp.activateIgnoringOtherApps true
     @runTaskDialog.makeFirstResponder @descriptionField
     @runTaskDialog.setTitle("Run Task")
     @runTaskDialog.makeKeyAndOrderFront(self)
     @runTaskDialog.center
   end
   
   ib_action :runTask
   def runTask(sender)
     taskName = @taskField.stringValue.to_s
     description = @descriptionField.stringValue.to_s
     @runStage.run_stage taskName, description
     @runTaskDialog.close
     resetFields
   end
   
   ib_action :closeTaskWindow
   def closeTaskWindow(sender)
     @runTaskDialog.close
     resetFields
   end
   
   private
   
   def resetFields
     @taskField.setStringValue ""
     @descriptionField.setStringValue ""
   end
   
   def create_status_bar
     @statusItem = OSX::NSStatusBar.systemStatusBar.statusItemWithLength(OSX::NSVariableStatusItemLength)
     path = NSBundle.mainBundle.pathForResource_ofType("icon-failure", "png")
     initial_icon = OSX::NSURL.fileURLWithPath("Resources/icon-failure.png")
     @statusItem.setImage NSImage.alloc.initByReferencingFile(path)
     @statusItem.setHighlightMode true
     @statusItem.setMenu @status_menu
     @statusItem.setTarget self
     update_menu
   end
   
   def update_menu hosts_list = nil
     build_project_menu hosts_list
     item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Quit", "quit:", "", 0)
     item.setTarget self

     item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Preferences", "show_preferences:", "", 1)
     item.setTarget self
     
     @statusItem
   end
   
   def build_project_menu hosts_list = nil
     lastIndex = 0
     hosts = hosts_list || @preferences_controller.hosts
     @webistrano_controller.fetch_projects(hosts).each do |project|
       item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("#{project.name.to_s} (#{project.host.url})", nil, "", lastIndex)
       item.setTarget self
       lastIndex += 1
       add_stages item, project
     end
   end
   
   def add_stages item, project
     sub_menu = NSMenu.alloc.init
     lastIndex = 0
     project.stages.each do |stage|
       sub_item = sub_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(stage.name, nil, "", lastIndex)
       sub_item.setTarget self
       sub_item.setRepresentedObject stage
       add_tasks sub_item, stage
       lastIndex += 1
     end
     
     item.setSubmenu sub_menu
   end
   
   def add_tasks item, stage
     sub_menu = NSMenu.alloc.init
     lastIndex = 0
     stage.tasks.each do |task|
       sub_item = sub_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(task.name, "clicked:", "", lastIndex)
       sub_item.setTarget self
       sub_item.setRepresentedObject task
       lastIndex += 1
     end
     item.setSubmenu sub_menu
   end
end
