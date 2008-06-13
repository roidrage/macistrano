require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  include OSX
  include NotificationHub

  notify :host_version_accepted, :when => :host_version_acceptable
  notify :host_version_not_accepted, :when => :host_version_inacceptable
  notify :host_credentials_invalid, :when => :host_credentials_invalid
  
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
    init_hosts
    self.initWithWindowNibName("preferences")
  end

  def register_defaults
    appDefaults = NSMutableDictionary.dictionary
    appDefaults.setObject_forKey([], "hosts")
    NSUserDefaults.standardUserDefaults.registerDefaults appDefaults
  end
  
  def init_hosts
    register_defaults
    configured_hosts = NSUserDefaults.standardUserDefaults.arrayForKey("hosts")
    @hosts ||= []
    configured_hosts.each do |data|
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
  
  ib_action :add do
    NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@newHostSheet, @preferencesWindow, nil, nil, nil)
    NSApp.endSheet @newHostSheet
  end
  
  ib_action :addFromSheet do
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
    add_host host
    @newHostSheet.orderOut self
    @tableView.reloadData
    host.find_projects
  end
  
  def host_version_not_accepted(notification)
    return if @hostField.nil?
    host = notification.object
    show_alert("The Webistrano version you're running is not suitable for use with Macistrano", "You need at least version #{Host::ACCEPT_VERSION.join(".")}.")
    reset_spinner
  end

  def host_credentials_invalid(notification)
    return if @hostField.nil?
    show_alert("The specified credentials are invalid.", "Please check username and password and try again.")
    reset_spinner
  end
  
  def show_alert(message, extended)
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle "OK"
    alert.setMessageText message
    alert.setInformativeText extended
    alert.setAlertStyle NSWarningAlertStyle
    alert.runModal
    alert.release
  end
  
  def reset_spinner
    @spinner.stopAnimation(self)
    @spinner.setHidden(true)
  end
  
  ib_action :cancelSheet do
    closeSheet
    reset_fields
    reset_spinner
  end

  ib_action :removeHost do
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
  
  def add_host host
    @hosts << host
    Keychain.add_password host
    save_hosts_to_preferences
    reset_fields
    reset_spinner
  end
  
  def save_hosts_to_preferences
    NSUserDefaults.standardUserDefaults.setObject_forKey(hosts_as_list, "hosts")
    NSUserDefaults.standardUserDefaults.synchronize
  end
  
  def hosts_as_list
    @hosts.collect do |host|
      [host.url, host.username]
    end
  end
  
  def reset_fields
    @hostField.setStringValue ""
    @newHostSheet.makeFirstResponder @hostField
    @passwordField.setStringValue ""
    @usernameField.setStringValue ""
  end
end
