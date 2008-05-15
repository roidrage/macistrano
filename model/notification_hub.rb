require 'osx/cocoa'

class NotificationHub
  class << self
    def fetched_projects_done projects
      NSNotificationCenter.defaultCenter.postNotificationName_object "FetchedProjectsDone", projects
    end
    
    def deployment_started
      NSNoficitationCenter.defaultCenter.postNotificationName_object "DeploymentStarted", nil
    end
    
    def observe_deployment_started object, selector
      NSNotificationCenter.defaultCenter.addObserver_selector_name_object object, selector, "DeploymentStarted", nil
    end
    
    def unobserve_deployment_started object
      NSNotificationCenter.defaultCenter.removeObserver_name_object object, "DeploymentStarted", nil
    end
  end
end