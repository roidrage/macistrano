require 'osx/cocoa'

module NotificationHub
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(*args)
    registered_notifications = self.class.instance_variable_get(:@registered_notifications)
    registered_notifications.each do |on, method|
      OSX::NSNotificationCenter.defaultCenter.addObserver_selector_name_object self, "#{method.to_s}:", on.to_s, nil
    end unless registered_notifications.nil?
    super(*args)
  end
  
  def method_missing(name, *args)
    if name.to_s.match(/^notify_/)
      event = name.to_s.gsub(/^notify_/, "")
      OSX::NSNotificationCenter.defaultCenter.postNotificationName_object event.to_s, args[0]
    else
      super
    end
  end
  
  module ClassMethods
    
    def notify method, options
      @registered_notifications ||= {}
      @registered_notifications[options[:when].to_s.gsub(/ /, "_").to_sym] = method
    end
  end
end