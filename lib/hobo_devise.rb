require 'hobo_devise/database_authenticable.rb'

class ActiveRecord::Base
  def self.hobo_devise_user_model(opts={})

    self.class_eval do
      hobo_user_model
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
