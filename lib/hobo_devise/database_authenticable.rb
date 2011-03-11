module HoboDevise
  def self.database_authenticable(model)
    model.class_eval do
      devise :database_authenticatable

      # Devise uses longer fields then Hobo for passwords
      fields do
        crypted_password          :string, :limit => 60
      end

      def password=(new_password)
        @password = new_password
        self.encrypted_password = password_digest(@password) if @password.present?
      end

      # Hobo shouldn't be able to access crypted_password or perform it's own password validation
      def crypted_password; end
      def crypted_password=(n); end
      def validate_current_password_when_changing_password; end

      # Some aliases for devise
      def password_salt; salt; end
      def password_salt=(n); salt=n; end
      def encrypted_password; read_attribute(:crypted_password); end
      def encrypted_password=(n); write_attribute(:crypted_password, n); end
      # (Should be login_attribute, not email_address?)
      def email; email_address; end
      def email(n); email_address = n; end

      ## This is c&p from devise sources. I'm not sure why, but it's necessary
      require 'bcrypt'
      def password_digest(password)
        ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
      end

      def valid_password?(password)
        bcrypt = ::BCrypt::Password.new(self.encrypted_password)
        password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
        Devise.secure_compare(password, self.encrypted_password)
      end

      def authenticated?(password)
        self.valid_password?(password)
      end
    end

  end
end
