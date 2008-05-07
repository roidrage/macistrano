require 'osx/cocoa'

class PreferencesController < OSX::NSWindowController
   include OSX
   ib_outlet :preferencesWindow
   
   def showPreferences
     bundle = NSBundle.loadNibNamed("preferences")
     
     preferencesWindow.makeKeyAndOrderFront(self)
   end
end
