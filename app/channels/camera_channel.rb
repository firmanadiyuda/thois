require "gphoto2"

class CameraChannel < ApplicationCable::Channel
  @camera = nil

  def initialize(*args)
    super
    @camera_mutex = Mutex.new
    @camera = nil
  end

  def subscribed
    stream_from "camera_channel"
  end

  def unsubscribed
    stop_camera_preview
  end

  def toggle_preview(data)
    if data["enabled"]
      start_camera_preview unless live_view_running?
    else
      stop_camera_preview if live_view_running?
    end
    ActionCable.server.broadcast("camera_channel", { liveview_status: live_view_running? })
  end

  def capture_image
    captured_image = nil
    detect_camera()

    @camera_mutex.synchronize do
      if @camera
        captured_image = @camera.capture
        encoded_image = Base64.strict_encode64(captured_image.data)
        ActionCable.server.broadcast("camera_channel", { captured_image: encoded_image })
        @raw = Raw.new
        @raw.save
        sleep(4)
        ActionCable.server.broadcast("camera_channel", { captured_image: nil })
      end
    end
  end

  private

  def live_view_running?
    @preview_thread&.alive? || false
  end

  def start_camera_preview
    return if live_view_running?

    detect_camera()

    if @camera
      @preview_thread = Thread.new do
        loop do
          preview_image = nil
          @camera_mutex.synchronize do
            preview_image = @camera.preview.data
          end
          encoded_image = Base64.strict_encode64(preview_image)
          ActionCable.server.broadcast("camera_channel", { preview: encoded_image })
          sleep(0.01)
        end
      end
    end
  end

  def stop_camera_preview
    @preview_thread.kill if @preview_thread
    @preview_thread = nil
    @camera_mutex.synchronize do
      if @camera
        @camera.close
        @camera = nil
      end
    end
  end

  private

  def detect_camera
    @camera_mutex.synchronize do
      begin
        @camera = GPhoto2::Camera.first unless @camera
        @camera["liveviewsize"] = "Medium"
        @camera.save
      rescue => e
          Rails.logger.debug e
      end
    end
  end
end
