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
  include NotificationHub
  
  notify :updateHostList, :when => :host_list_updated
  notify :add_projects, :when => :project_loaded
  notify :add_stages, :when => :stages_loaded
  notify :add_tasks, :when => :tasks_loaded
   
  attr_reader :status_menu
  attr_accessor :loaded
   
  ib_outlet :runTaskDialog
  ib_outlet :taskField
  ib_outlet :descriptionField
   
  def awakeFromNib
    @webistrano_controller = WebistranoController.alloc.init
    @status_menu = OSX::NSMenu.alloc.init
    @preferences_controller = PreferencesController.alloc.init
    create_status_bar
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
    # @runStage = sender.representedObject.stage
    # @taskField.setStringValue sender.representedObject.name
    # NSApp.activateIgnoringOtherApps true
    # @runTaskDialog.makeFirstResponder @descriptionField
    # @runTaskDialog.setTitle("Run Task")
    # @runTaskDialog.makeKeyAndOrderFront(self)
    # @runTaskDialog.center
  end
  
  def add_projects(notification)
    options = notification.object
    options[:projects].each do |project|
      item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("#{project.name.to_s} (#{project.host.url})", nil, "", @statusItem.menu.numberOfItems)
      item.setTarget self
      item.setRepresentedObject project
    end
  end
  
  ib_action :runTask
  def runTask(sender)
    taskName = @taskField.stringValue.to_s
    description = @descriptionField.stringValue.to_s
    @runStage.run_stage taskName, description
    @runTaskDialog.close
    reset_fields
  end
   
  ib_action :closeTaskWindow
  def closeTaskWindow(sender)
    @runTaskDialog.close
    reset_fields
  end
  
  def add_stages(notification)
    project = notification.object
    idx = @statusItem.menu.indexOfItemWithRepresentedObject(project)
    if idx >= 0
      item = @statusItem.menu.itemAtIndex(idx)
      sub_menu = NSMenu.alloc.init
      lastIndex = 0
      project.stages.each do |stage|
        sub_item = sub_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(stage.name, nil, "", lastIndex)
        sub_item.setTarget self
        sub_item.setRepresentedObject stage
        lastIndex += 1
      end
      item.setSubmenu sub_menu
      item.setEnabled true
    end
    
  end
  
  def add_tasks(notification)
    stage = notification.object
    idx = @statusItem.menu.indexOfItemWithRepresentedObject(stage.project)
    project_menu_item = @statusItem.menu.itemAtIndex(idx)
    
    idx = project_menu_item.submenu.indexOfItemWithRepresentedObject(stage)
    stage_menu_item = project_menu_item.submenu.itemAtIndex(idx)
    
    tasks_menu = NSMenu.alloc.init
    lastIndex = 0
    stage.tasks.each do |task|
      sub_item = tasks_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(task.name, "clicked:", "", lastIndex)
      sub_item.setTarget self
      sub_item.setRepresentedObject task
      lastIndex += 1
    end
    stage_menu_item.setSubmenu tasks_menu
    stage_menu_item.setEnabled true
  end
  
  private
   
  def reset_fields
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
    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Quit", "quit:", "", 0)
    item.setTarget self

    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Preferences", "show_preferences:", "", 1)
    item.setTarget self
    
    @statusItem
    
    fetch_projects
  end
  
  def fetch_projects
    hosts = @preferences_controller.hosts
    hosts.each do |host|
      host.find_projects
    end
  end
end
