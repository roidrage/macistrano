#
#  project_controller.rb
#  macistrano
#
#  Created by Pom on 24.04.08.
#  Copyright (c) 2008 Paperplanes, Mathias Meyer. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'growl_notifier'
require 'notification_hub'

class ProjectController < OSX::NSWindowController
  include OSX
  include NotificationHub
  
  GROWL_MESSAGE_TYPES = {:deployment_complete => "Deployment completed", :deployment_started => "Deployment started", :deployment_failed => "Deployment failed"}
  
  notify :add_host, :when => :host_fully_loaded
  notify :remove_host, :when => :host_removed
  notify :remove_loading, :when => :all_hosts_loaded
  notify :build_completed, :when => :stage_build_completed
  notify :build_running, :when => :stage_build_running
  notify :update_status_window, :when => :deployment_status_updated
  
  attr_reader :status_menu, :webistrano_controller
  attr_accessor :loaded, :growl_notifier
   
  ib_outlet :runTaskDialog
  ib_outlet :taskField
  ib_outlet :descriptionField
  ib_outlet :preferences_controller
  ib_outlet :statusHudWindow
  ib_outlet :statusHudWindowText
  
  ib_action :show_about do
    NSApp.orderFrontStandardAboutPanel self
  end
  
  ib_action :show_status do
    @statusHudWindow.makeKeyAndOrderFront(self)
  end
  
  def awakeFromNib
    @webistrano_controller = WebistranoController.alloc.init
    @status_menu = OSX::NSMenu.alloc.init
    show_preferences self if @preferences_controller.hosts.empty?
    webistrano_controller.hosts = @preferences_controller.hosts
    create_status_bar
    init_growl
    @statusHudWindow.setFloatingPanel true
  end
  
  def init_growl
    @growl_notifier = Growl::Notifier.alloc.init
    @growl_notifier.start('Macistrano', GROWL_MESSAGE_TYPES.collect {|key, value| value})
  end
  
  def remove_loading(notification)
    item = @statusItem.menu.itemWithTitle("Loading...")
    @statusItem.menu.removeItem(item) unless item.nil?
    webistrano_controller.setup_build_check_timer
  end
  
  def add_host(notification)
    notification.object.projects.each do |project|
      item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("#{project.name.to_s} (#{project.host.url})", nil, "", 0)
      item.setTarget self
      item.setRepresentedObject project
      add_stages project
    end
  end
  
  def remove_host(notification)
    host = notification.object
    @statusItem.menu.itemArray.each do |item|
      if item.representedObject.is_a?(Project)
        @statusItem.menu.removeItem(item) if item.representedObject.host.eql?(host)
      end
    end
  end
  
  def build_running(notification)
    set_status_icon("success-building")
    set_stage_submenu_enabled(notification.object, false, "success-building")
    webistrano_controller.setup_deployment_status_timer(notification.object)
  end
  
  def set_stage_submenu_enabled(deployment, enabled, icon)
    index = @statusItem.menu.indexOfItemWithRepresentedObject deployment.stage.project
    unless index == -1
      project_menu = @statusItem.menu.itemAtIndex(index).submenu
      stage_menu_index = project_menu.indexOfItemWithRepresentedObject deployment.stage
      stage_menu_item = project_menu.itemAtIndex(stage_menu_index)
      stage_menu_item.setImage get_icon(icon)
      stage_menu = stage_menu_item.submenu
      stage_menu.itemArray.each do |item|
        item.setEnabled enabled
      end
    end
  end
  
  def update_status_window(notification)
    puts "hello"
    @statusHudWindowText.setStringValue notification.object.log
  end
  
  def build_completed(notification)
    icon = ""
    case notification.object.success
    when true:
      notify_growl GROWL_MESSAGE_TYPES[:deployment_complete], notification.object
      icon = "success"
    when false:
      notify_growl GROWL_MESSAGE_TYPES[:deployment_failed], notification.object
      icon = "failure"
    end
    set_stage_submenu_enabled(notification.object, true, icon)
    set_status_icon icon
  end

  def notify_growl(message, deployment)
    @growl_notifier.notify(message, message, "Stage #{deployment.stage.name} of project #{deployment.stage.project.name} (Host: #{deployment.stage.project.host.url})")
  end
  
  def set_status_icon(icon)
    @statusItem.setImage get_icon(icon)
  end
  
  def get_icon(icon)
    path = NSBundle.mainBundle.pathForResource_ofType("icon-#{icon}", "png")
    NSImage.alloc.initByReferencingFile(path)
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
  
  def add_projects(notification)
    options = notification.object
    options[:projects].each do |project|
      item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("#{project.name.to_s} (#{project.host.url})", nil, "", @statusItem.menu.numberOfItems)
      item.setTarget self
      item.setRepresentedObject project
    end
  end
  
  ib_action :runTask do
    taskName = @taskField.stringValue.to_s
    description = @descriptionField.stringValue.to_s
    @runStage.run_stage taskName, description
    @runTaskDialog.close
    reset_fields
  end
   
  ib_action :closeTaskWindow do
    @runTaskDialog.close
    reset_fields
  end
  
  def add_stages(project)
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
        add_tasks(stage, sub_item)
      end
      item.setSubmenu sub_menu
      item.setEnabled true
    end
  end
  
  def add_tasks(stage, parent_item)
    stage_menu_item = parent_item
    
    tasks_menu = NSMenu.alloc.init
    lastIndex = 0
    stage.tasks.each do |task|
      sub_item = tasks_menu.insertItemWithTitle_action_keyEquivalent_atIndex_(task.name, "clicked:", "", lastIndex)
      sub_item.setTarget self
      sub_item.setRepresentedObject task
      lastIndex += 1
    end
    tasks_menu.setAutoenablesItems false
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
    set_status_icon 'success'
    @statusItem.setHighlightMode true
    @statusItem.setMenu @status_menu
    @statusItem.setTarget self
    update_menu
  end
   
  def update_menu hosts_list = nil
    item = NSMenuItem.alloc.initWithTitle_action_keyEquivalent("Loading...", nil, "")
    item.setEnabled false
    @statusItem.menu.insertItem_atIndex(item, 0)
    
    @statusItem.menu.insertItem_atIndex(NSMenuItem.separatorItem, 1)
    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Show Status Window", "show_status:", "", 2)
    item.setTarget self

    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Preferences", "show_preferences:", "", 3)
    item.setTarget self

    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("About", "show_about:", "", 4)
    item.setTarget self
    @statusItem.menu.insertItem_atIndex(NSMenuItem.separatorItem, 5)

    item = @statusItem.menu.insertItemWithTitle_action_keyEquivalent_atIndex_("Quit", "quit:", "", 6)
    item.setTarget self

    fetch_projects
  end
  
  def fetch_projects
    hosts = @preferences_controller.hosts
    hosts.each do |host|
      host.find_projects
    end
  end
end
