class ProgressChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "progress_channel_#{params[:event_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
