require File.join(File.dirname(__FILE__), '/spec_helper')

require 'rubygems'
gem 'rspec'
require 'notification_hub'

class NotifyMe < OSX::NSObject
  include NotificationHub
end

describe NotifyMe, "when registering for a notification" do
  before do
    NotifyMe.instance_variable_set(:@registered_notifications, nil)
  end
  
  it "should add the notification to the class variable" do
    NotifyMe.instance_eval do
      notify :my_method, :when => "something_happens"
    end
    
    NotifyMe.instance_variable_get(:@registered_notifications).should == {:something_happens, :my_method}
  end
  
  it "should only define one notification method for a given event" do
    NotifyMe.instance_eval do
      notify :my_method, :when => "something_happens"
      notify :my_method, :when => "something_happens"
    end
    
    NotifyMe.instance_variable_get(:@registered_notifications).should == {:something_happens, :my_method}
  end
  
  it "should convert an event with spaces into underscores to allow calling them through the notify_ mechanism" do
    NotifyMe.instance_eval do
      notify :my_method, :when => "something incredible happens"
    end
    
    NotifyMe.instance_variable_get(:@registered_notifications).keys.first.should == :something_incredible_happens
  end
end

describe NotifyMe, "when sending a notification" do
  include NotificationHub
  
  before do
    NotifyMe.instance_eval do
      notify :notify_me, :when => "hell_breaks_lose"
      def notify_me
      end
    end
    
    @notified = NotifyMe.new
  end
  
  it "should call the specified method on the specified event" do
    @notified.should_receive(:notify_me)
    
    notify_hell_breaks_lose
  end
  
  it "should pass other methods not starting with notify_ on to the superclass" do
    received = false
    class NotifyYou < NotifyMe
      include NotificationHub
    end
    
    notify = NotifyYou.new
    class NotifyMe < OSX::NSObject
      attr_accessor :received_message
      alias_method :old_method_missing, :method_missing
      def method_missing(name, *args)
        @received_message = true
      end
    end
    notify.received
    notify.received_message.should be_true
  end
  
  it "should not notify on a different event" do
    @notified.should_not_receive(:notify_me)
    notify_its_like_heaven
  end
end