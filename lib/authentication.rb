if defined? ActionController::Base
  require File.join(File.dirname(__FILE__), 'authentication', 'authentication_system')

  ActionController::Base.send(:include, Authentication::AuthenticationSystem)
end

module Authentication
  
end