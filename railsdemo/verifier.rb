class User < ActiveRecord::Base
  class << self
    def verifier_for(purpose)
      @verifiers ||= {}
      @verifiers.fetch(purpose) do |p|
        @verifiers[p] = Rails.application.message_verifier("#{self.name}-#{p.to_s}")
      end
    end
  end

  def reset_password_token
    verifier = self.class.verifier_for('reset-password') # Unique for each type of messages
    verifier.generate([id, Time.now])
  end

  def reset_password!(token, new_password, new_password_confirmation)
    # This raises an exception if the message is modified
    user_id, timestamp = self.class.User.verifier_for('reset-password').verify(token)

    if timestamp > 1.day.ago
      self.password = new_password
      self.password_confirmation = new_password_confirmation
      save!
    else
      # Token expired
      # ...
    end
  end
end

class Notifier < ActionMailer::Base
  def reset_password(user)
    @user = user
    @reset_password_url = password_reset_url(token: @user.reset_password_token)
    mail(to: user.email, subject: "Your have requested to reset your password")
  end
end