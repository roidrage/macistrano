require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  
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
    hosts = NSUserDefaults.standardUserDefaults.arrayForKey("hosts")
  end
  
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

  def showPreferences
    NSApp.activateIgnoringOtherApps true
    self.showWindow(self)
    @preferencesWindow.makeKeyAndOrderFront(self)
    @preferencesWindow.setTitle("Preferences")
  end
  
  def numberOfRowsInTableView(tableView)
    1
  end
  
  def tableView_objectValueForTableColumn_row(tableView, column, row)
    puts "request for #{column}/#{row}"
    "host"
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
    host.password = @passwordField.stringValue
    addHost host
    @newHostSheet.orderOut self
  end
  
  ib_action :cancelSheet
  def cancelSheet(id)
    closeSheet
  end
  
  def closeSheet
    @newHostSheet.orderOut self
  end
  
  def addHost host
    @hosts ||= []
    @hosts << host
    saveHostsToPreferences
  end
  
  def saveHostsToPreferences
    NSUserDefaults.standardUserDefaults.setObject_forKey(hosts_list, "hosts")
  end
  
  def hosts_list
    @hosts.collect do |host|
      [host.url, host.username]
    end
  end
end
