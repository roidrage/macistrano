require 'osx/cocoa'
include OSX

class Operation < OSX::NSOperation
  
  def initWithDelegate delegate
    init
    puts "init"
    @delegate = delegate
    @done = false
    self
  end
  
  def start
    puts "posting from #{NSThread.currentThread.isMainThread}"
    @delegate.was_called(self)
    @done = true
  end
  
  def main
    puts "main"
  end
  
  def isReady
    !@done
  end
  
  
  def isExecuting
    puts "executing #{!@done}"
    @done
  end
  
  def isConcurrent
    puts "concurrent"
    true
  end
  
  def isFinished
    puts "finished #{@done}"
    @done
  end
end

class OperationRunner
  def was_called(sender)
    puts "sender called at #{Time.now.to_s}"
  end

  def run
    puts "running from #{NSThread.currentThread.isMainThread}"
    queue = OSX::NSOperationQueue.alloc.init

    queue.addOperation Operation.alloc.initWithDelegate(self)
  end
end


OperationRunner.new.run
