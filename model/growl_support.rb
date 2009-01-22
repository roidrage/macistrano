require 'growl_notifier'

module GrowlSupport
  GROWL_MESSAGE_TYPES = {:deployment_complete => "Deployment completed",
                         :deployment_started => "Deployment started",
                         :deployment_failed => "Deployment failed",
                         :deployment_canceled => "Deployment cancelled"}

  def notify_growl(notification)
    deployment = notification.object
    message = case when "success":
      GROWL_MESSAGE_TYPES[:deployment_complete]
    when "canceled":
      GROWL_MESSAGE_TYPES[:deployment_canceled]
    when "failed":
      GROWL_MESSAGE_TYPES[:deployment_failed]
    end
    @growl_notifier.notify(message, message, "Stage #{deployment.stage.name} of project #{deployment.stage.project.name} (Host: #{deployment.stage.project.host.url})")
  end
  
  def init_growl
    @growl_notifier = Growl::Notifier.alloc.init
    @growl_notifier.start('Macistrano', GROWL_MESSAGE_TYPES.collect {|key, value| value})
  end
end