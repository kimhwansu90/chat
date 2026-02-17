module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      username = request.session[:username]
      if username.present?
        username
      else
        reject_unauthorized_connection
      end
    end
  end
end
