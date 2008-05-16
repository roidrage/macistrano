require '../model/load_operation'
require 'osx/cocoa'

include OSX

class Runner < NSWindowController
  def run
    queue = NSOperationQueue.alloc.init
    queue.addOperation LoadOperation.alloc.initWithURL_delegate_representedObject(NSURL.URLWithString('http://192.168.2.100/apache_pb.gif'), self, self)
    queue.waitUntilAllOperationsAreFinished
  end
  
  def url_finished *args
    puts "finished"
  end
end

Runner.new.run