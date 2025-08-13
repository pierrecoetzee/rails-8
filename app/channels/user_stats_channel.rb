class UserStatsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{current_user.id}_stats", nil, coder: ActiveSupport::JSON
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def current_user
    # Assuming you have authentication set up in your Action Cable connection
    Current.user
  end
end