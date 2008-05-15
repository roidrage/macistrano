require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  include OSX

  ib_outlet :preferencesWindow
  ib_outlet :tableView
  ib_outlet :newHostSheet
  ib_outlet :addButton
  ib_outlet :cancelButton
  ib_outlet :spinner
  ib_outlet :hostField
  ib_outlet :usernameField
  ib_outlet :passwordField
  
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
      host = Host.new
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
    host = Host.new
    host.url = @hostField.stringValue
    host.username = @usernameField.stringValue
    host.password = @passwordField.stringValue.to_s
    addHost host
    @newHostSheet.orderOut self
    @tableView.reloadData
    notifyHostUpdate
  end

  def notifyHostUpdate
    NSNotificationCenter.defaultCenter.postNotificationName_object "HostListUpdated", hosts
  end
  
  ib_action :cancelSheet
  def cancelSheet(id)
    closeSheet
    resetFields
  end

  ib_action :removeHost
  def removeHost sender
    unless @tableView.selectedRow < 0
      host = @hosts[@tableView.selectedRow]
      Keychain.remove_password host
      @hosts.delete_at(@tableView.selectedRow)
      saveHostsToPreferences
      notifyHostUpdate
      @tableView.reloadData
    end
  end
  
  def closeSheet
    @newHostSheet.orderOut self
  end
  
  def addHost host
    @hosts << host
    Keychain.add_password host
    saveHostsToPreferences
    resetFields
  end
  
  def saveHostsToPreferences
    NSUserDefaults.standardUserDefaults.setObject_forKey(hostsAsList, "hosts")
  end
  
  def hostsAsList
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
