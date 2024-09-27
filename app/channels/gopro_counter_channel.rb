class GoproCounterChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "gopro_counter_channel_#{params[:event_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
