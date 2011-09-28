require 'hobo_devise/database_authenticable.rb'
require 'hobo_devise/devise_oauth2_facebook.rb'

class ActiveRecord::Base
  def self.hobo_devise_user_model(opts={})

    self.class_eval do
      hobo_user_model
      alias_attribute :email_address, :email
      fields do
        email         :email_address, :login => true
      end
    end

    opts.reverse_merge!({ :auth_methods => :database_authenticatable })

    user_class = self

    if opts[:auth_methods].is_a? Array
      for auth_method in opts[:auth_methods]
        HoboDevise.send(auth_method, user_class) if HoboDevise.methods.include? auth_method.to_s
      end
    else
      auth_method = opts[:auth_methods]
      HoboDevise.send(auth_method, user_class) if HoboDevise.methods.include? auth_method.to_s
    end
  end

end

class ActionController::Base
  def self.hobo_devise_oauth2_facebook_controller(model)
    @@model = model
    self.class_eval do
      hobo_user_controller
      include DeviseOauth2Facebook::FacebookConsumerHelper
      include DeviseOauth2Facebook::ControllerMethods

      def resource_name; @@model.to_s.downcase; end
      def resource_class; @@model; end
      def initialize; action_methods.add "callback"; end

      def set_flash_message(type, message)
        flash[type] = message
      end

      def sign_in_and_redirect(resource_name, user)
        redirect_to "/"
        options = {:notice => ht(:"#{model.to_s.underscore}.messages.logout", :default=>["You have logged out."]),
                                      :redirect_to => base_url}
        sign_user_in(user, options)
      end
    end
  end
end
