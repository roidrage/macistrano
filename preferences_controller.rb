require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
  def init
    self.initWithWindowNibName("preferences")
  end

  include OSX
 
  ib_outlet :preferencesWindow
 
  def showPreferences
    NSApp.activateIgnoringOtherApps true
    self.showWindow(self)
    @preferencesWindow.makeKeyAndOrderFront(self)
  end
end
