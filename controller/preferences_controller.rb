require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  include OSX
  include NotificationHub

  notify :host_version_accepted, :when => :host_version_acceptable
  notify :host_version_not_accepted, :when => :host_version_inacceptable
  
  ib_outlet :preferencesWindow
  ib_outlet :tableView
  ib_outlet :newHostSheet
  ib_outlet :addButton
  ib_outlet :cancelButton
  ib_outlet :spinner
  ib_outlet :hostField
  ib_outlet :usernameField
  ib_outlet :passwordField
  
  def awakeFromNib
  end
  
  def init
    initHosts
    self.initWithWindowNibName("preferences")
  end

  def registerDefaults
    appDefaults = NSMutableDictionary.dictionary
    appDefaults.setObject_forKey([], "hosts")
    NSUserDefaults.standardUserDefaults.registerDefaults appDefaults
  end
  
  def initHosts
    registerDefaults
    configuredHosts = NSUserDefaults.standardUserDefaults.arrayForKey("hosts")
    @hosts ||= []
    configuredHosts.each do |data|
      host = Host.alloc.init
      host.url = data[0]
      host.username = data[1]
      Keychain.find_password host
      @hosts << host
    end
    fetchPasswords
  end
  
  def fetchPasswords
    @hosts.each do |host|
      Keychain.find_password host
    end
  end
  
  def showPreferences
    NSApp.activateIgnoringOtherApps true
    self.showWindow(self)
    @preferencesWindow.makeKeyAndOrderFront(self)
    @preferencesWindow.setTitle("Preferences")
  end
  
  def numberOfRowsInTableView(tableView)
    @hosts.size
  end
  
  def tableView_objectValueForTableColumn_row(tableView, column, row)
    @hosts[row].url
  end
  
  ib_action :add
  def add(id)
    NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@newHostSheet, @preferencesWindow, nil, nil, nil)
    NSApp.endSheet @newHostSheet
  end
  
  ib_action :addFromSheet
  def addFromSheet(id)
    @spinner.startAnimation(self)
    @spinner.setHidden(false)
    host = Host.new
    host.url = @hostField.stringValue
    host.username = @usernameField.stringValue
    host.password = @passwordField.stringValue.to_s
    host.schedule_version_check
  end

  def host_version_accepted(notification)
    # ignore messages to instances not connected to the nib. weird side effect of having an instance
    # of the controller in the project_controller
    return if @hostField.nil?
    host = notification.object
    addHost host
    @newHostSheet.orderOut self
    @tableView.reloadData
    host.find_projects
  end
  
  def host_version_not_accepted(notification)
    return if @hostField.nil?
    host = notification.object
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle "OK"
    alert.setMessageText "The Webistrano version you're running is not suitable for use with Macistrano"
    alert.setInformativeText "You need at least version #{Host::ACCEPT_VERSION.join(".")}."
    alert.setAlertStyle NSWarningAlertStyle
    alert.runModal
    alert.release
    
    reset_spinner
  end
  
  def reset_spinner
    @spinner.stopAnimation(self)
    @spinner.setHidden(true)
  end
  
  ib_action :cancelSheet
  def cancelSheet(id)
    closeSheet
    resetFields
    reset_spinner
  end

  ib_action :removeHost
  def removeHost sender
    unless @tableView.selectedRow < 0
      host = @hosts[@tableView.selectedRow]
      Keychain.remove_password host
      @hosts.delete_at(@tableView.selectedRow)
      save_hosts_to_preferences
      notify_host_removed host
      @tableView.reloadData
    end
  end
  
  def closeSheet
    @newHostSheet.orderOut self
  end
  
  def addHost host
    @hosts << host
    Keychain.add_password host
    save_hosts_to_preferences
    resetFields
  end
  
  def save_hosts_to_preferences
    NSUserDefaults.standardUserDefaults.setObject_forKey(hosts_as_list, "hosts")
  end
  
  def hosts_as_list
    @hosts.collect do |host|
      [host.url, host.username]
    end
  end
  
  def resetFields
    @hostField.setStringValue ""
    @newHostSheet.makeFirstResponder @hostField
    @passwordField.setStringValue ""
    @usernameField.setStringValue ""
  end
end
