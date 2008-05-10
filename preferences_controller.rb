require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  
  def init
    self.initWithWindowNibName("preferences")
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

  def hosts
  end
  
  def showPreferences
    NSApp.activateIgnoringOtherApps true
    self.showWindow(self)
    @preferencesWindow.makeKeyAndOrderFront(self)
    @preferencesWindow.setTitle("Preferences")
  end
  
  def numberOfRowsInTableView(tableView)
    puts "number of rows in table requested"
    1
  end
  
  def tableView_objectValueForTableColumn_row(tableView, column, row)
    puts "request for #{column}/#{row}"
    "host"
  end
  
  ib_action :add
  def add(id)
    NSApp.beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(@newHostSheet, @preferencesWindow, nil, nil, nil)
    # NSApp.runModalForWindow @newHostSheet
    NSApp.endSheet @newHostSheet

  end
  
  ib_action :cancelSheet
  def cancelSheet(id)
    # NSApp.endSheet @preferencesWindow
    # NSApp.stopModal
    @newHostSheet.orderOut self
  end
end
