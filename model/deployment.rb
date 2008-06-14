require 'osx/cocoa'

class Deployment < OSX::NSObject
  attr_accessor :webistrano_id, :task, :created_at, :completed_at
end