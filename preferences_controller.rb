require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  attr_accessor :hosts
  
  def init
    self.initWithWindowNibName("preferences")
  end

  include OSX

  ib_outlet :preferencesWindow
  ib_outlet :tableView

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
  def add id
    @tableView.selectRow_byExtendingSelection(0, false)
    @tableView.editColumn_row_withEvent_select(0, 0, nil, true)
  end
end
