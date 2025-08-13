module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # Just set the user without any logging for now
      self.current_user = User.first

      unless current_user
        reject_unauthorized_connection
      end
    end


    private

    def find_verified_user
      # First try to get user from cookies (web session)
      if session_id = cookies.encrypted[:session_id]
        if session = Session.find_by(id: session_id)
          # Rails.logger.info "Found user via session: #{session.user.id}"
          return session.user
        end
      end

      # Fallback: try signed cookies
      if session_id = cookies.signed[:session_id]
        if session = Session.find_by(id: session_id)
          # Rails.logger.info "Found user via signed session: #{session.user.id}"
          return session.user
        end
      end

      # Rails.logger.error "No valid session found for Action Cable connection"
      reject_unauthorized_connection
    end
  end
end