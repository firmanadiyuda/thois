require "singleton"
require "gphoto2"

class CameraService
  include Singleton

  def initialize
    @mutex = Mutex.new
    @camera = nil
    @liveview_thread = nil
    @countdown_duration = 5
    @preview_duration = 3
  end

  def with_camera
    @mutex.synchronize do
      @camera ||= initialize_camera
      yield @camera if block_given?
    end
  end

  def start_liveview
    return if @liveview_thread&.alive?

    @liveview_thread = Thread.new do
      loop do
        begin
          preview_image = nil
          with_camera do |camera|
              preview_image = camera.preview.data
            end
            encoded_image = Base64.strict_encode64(preview_image)
            ActionCable.server.broadcast("camera_channel", { liveview: encoded_image, liveview_status: true, model: model })
          rescue => e
            stop_liveview
          end
          # Set liveview fps limit.
          # 0.04 = 24fps
          sleep(0.04)
        end
      end
  end

  def stop_liveview
    ActionCable.server.broadcast("camera_channel", { liveview_status: false })
    reset_camera
    @liveview_thread&.kill
    @liveview_thread = nil
    ActionCable.server.broadcast("camera_channel", { liveview_status: false })
  end

  def set_preview_duration(d)
    @preview_duration = d + 1 # + 1 for capture time dispensation
  end

  def set_countdown_duration(d)
    @countdown_duration = d
  end

  def capture_image
    ActionCable.server.broadcast("camera_channel", { countdown_duration: @countdown_duration })
    sleep(@countdown_duration)

    encoded_image = nil

    with_camera do |camera|
      captured_image = camera.capture
      encoded_image = Base64.strict_encode64(captured_image.data)
      ActionCable.server.broadcast("camera_channel", { captured_image: encoded_image })
    end

    sleep(@preview_duration)
    ActionCable.server.broadcast("camera_channel", { end_preview: true })
    encoded_image
  end

  def liveview_running?
    @liveview_thread&.alive? || false
  end

  def connected?
    @liveview_thread&.alive? || false
  end

  def model
    @mutex.synchronize do
      if @camera
        @camera["cameramodel"].value || nil
      end
    end
  end

  private

  def initialize_camera
      camera = GPhoto2::Camera.first
      camera["liveviewsize"] = "Medium"
      camera.save
      camera
  end

  def reset_camera
    @mutex.synchronize do
      if @camera
        @camera.close
        @camera = nil
      end
    end
  end
end
