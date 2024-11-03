class SessionCountChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "session_count_channel_#{params[:event_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
