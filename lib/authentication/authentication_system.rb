module Authentication
  module AuthenticationSystem
    protected

    def logged_in?
      if session[:user_id]
        # Destroy session if session[:user_id] is not available!
        @current_user ||= begin
          User.find(session[:user_id]) 
        rescue
          reset_session
          nil
        end
      end
    end

    def current_user
      return @current_user if logged_in?
    end

    def current_user=(user)
      unless user.blank?
        session[:user_id] = user.id
        @current_user = user
      end
    end

    # Devise compatibility
    alias_method :user_signed_in?, :logged_in?

    def self.included(base)
      base.send :helper_method, :logged_in?, :user_signed_in?, :current_user, :back_or_default
    end

    def login_required!
      logged_in? || access_denied
    end

    # Devise compatibility
    alias_method :authenticate_user!, :login_required!

    def access_denied(msg = I18n.t(:"authentication.failure.unauthenticated"))
      store_location
      redirect_to main_app.new_session_path, alert: msg
    end

    alias_method :permission_denied, :access_denied

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location(options = {})
      # UPDATE RAILS 3.1
      # NON-GET request cannot be redirected!
      # Instead  store the actual location for NON-GET request
      options = { 
        return_to: request.get? ? 
          request.url : 
          request.env["HTTP_REFERER"] 
      }.merge(options)
      session[:return_to] = options[:return_to]
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default = nil)
      redirect_to(back_or_default(default))
      session[:return_to] = nil
    end

    # Returns the URI stored by the most recent store_location call or
    # to the passed default.
    def back_or_default(default = nil)
      default ||= root_path
      session[:return_to] || default
    end
  end # End module
end # End module
  