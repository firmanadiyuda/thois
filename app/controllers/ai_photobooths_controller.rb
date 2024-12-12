require "escpos" # Pastikan modul helpers di-load
require "escpos/helpers" # Pastikan modul helpers di-load

class AiPhotoboothsController < ApplicationController
  def connect
    begin
      CameraService.instance.start_liveview
    rescue => e
      Rails.logger.debug e.message
    end
  end

  def capture
    if CameraService.instance.liveview_running?
      @event = Event.find(params[:event_id])

      # Set camera countdown and preview duration
      CameraService.instance.set_countdown_duration(3)
      CameraService.instance.set_preview_duration(3)

      # Capture image from camera and get encoded base64 image
      encoded_image = CameraService.instance.capture_image

      # Decode image from base64
      decoded_image = Base64.strict_decode64(encoded_image)

      # Build a temporary file for the decoded base64 image
      tempfile = Tempfile.new([ "image", ".jpg" ])
      tempfile.binmode
      tempfile.write(decoded_image)
      tempfile.rewind

      # Simulate an file field form
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: "#{SecureRandom.uuid}.jpg",
        type: "image/jpg"
      )

      # Get running session or create one if none
      @session = @event.session.find_or_create_by(status: "capturing")

      # Save image to raw db
      @raw = @session.raw.find_or_create_by(filetype: "image")
      @raw.filename = file
      @raw.save

      # Delete temp file
      tempfile.close
      tempfile.unlink

      # Open recently raw image
      File.open(@raw.filename.current_path) do |file|
        # Resize image
        image = MiniMagick::Image.open(@raw.filename.current_path)
        image.auto_orient
        # image.resize "1200x1800"
        image.resize "1800x1200"
        image.gravity "center"
        # image.crop "1080x1800+60+0"
        image.crop "1800x1080+60+0"
        # image.resize "1200x2000"
        image.resize "2000x1200"
        # image.crop "1200x1800+0+100"
        image.crop "1800x1200+0+100"
        image.quality "90"
        image.strip

        # Give an overlay
        overlay = MiniMagick::Image.open(@event.ai_photobooth.overlay.current_path)
        result = image.composite(overlay) do |c|
          c.gravity "center"
          c.compose "Over"
        end
        result.strip

        tempfile = Tempfile.new([ SecureRandom.uuid, ".jpg" ])
        result.write(tempfile.path)

        # Save image to export db
        @export = @session.export.find_or_create_by(filetype: "image")
        @export.filename = tempfile
        @export.save

        # Delete temp file
        tempfile.close
        tempfile.unlink
      end

      respond_to do |format|
          format.json { { status: "ok" } }
      end
    end
  end

  def toggle_liveview
    # Check if liveview curently running
    if CameraService.instance.liveview_running?
      CameraService.instance.stop_liveview
    else
      CameraService.instance.start_liveview
    end
  end

  def liveview_operator
    ActionCable.server.broadcast("camera_channel", { operator_instruction: "liveview" })
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")
    @connected = CameraService.instance.connected?
    ActionCable.server.broadcast("camera_channel", { liveview_status: CameraService.instance.liveview_running? })
  end

  def liveview
    connect
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")
    render layout: "liveview"
  end

  def gallery
    @event = Event.find(params[:event_id])
    @sessions = @event.session.order(created_at: :desc)
    render layout: "liveview"
  end

  def select_theme
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")
    @selected_themes = AiTheme.where(id: @event.ai_photobooth.selected_themes)

    id = SqidsService.new([ @session.id ]).call
    @qrurl = "tholee.my.id/d/#{id}"

    render layout: "liveview"
  end

  def select_photo_operator
    ActionCable.server.broadcast("camera_channel", { operator_instruction: "select_photo" })
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")
  end

  def select_photo_operator_id
    ActionCable.server.broadcast("camera_channel", { operator_instruction: "select_photo_id", id: params[:id] })
  end

  def finish_operator
    ActionCable.server.broadcast("camera_channel", { operator_instruction: "finish" })
    @event = Event.find(params[:event_id])
    sleep 3
    respond_to do |format|
      format.html { redirect_to event_photobooth_liveview_operator_url(@event) }
    end
  end

  def finish
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")

    Rails.logger.debug(params[:selected_theme])
    @session.ai_theme_id = params[:selected_theme]
    @session.status = "processing"
    @session.save

    @new_session = @event.session.find_or_create_by(status: "capturing")

    # Dispatch Photobooth Job
    AiPhotoboothJob.perform_later(@session)

    qr(@session.id)

    respond_to do |format|
      format.html { redirect_to event_ai_photobooth_liveview_url(@event) }
    end
  end

  def print_photo
    @session = Session.find(params[:session_id])
    @export = @session.export.find_by(printable: true)

    # Search printer by name
    printer = Cups::Printer.get_destination("HiTi_P510S_2")

    # Set paper size from configuration
    paper = @session.event.photobooth.paper

    # Print to printer
    system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{@export.filename.current_path}")
  end

  def print_qr
    session_id = params[:session_id]
    qr(session_id)
  end

  def qr(session_id)
    @session = Session.find(session_id)
    id = SqidsService.new([ @session.id ]).call

    @printer = Escpos::Printer.new

    # Normal size (1x1): \x1D\x21\x00
    # 2x width and 2x height: \x1D\x21\x11
    # 3x width and 3x height: \x1D\x21\x22
    # 4x width and 4x height: \x1D\x21\x33

    qr_data = "https://tholee.my.id/d/#{id}"

    @printer << "\n\n\n"  # Print 3 empty lines
    @printer << "\x1B\x61\x01" # ESC a 1 -> Align center

    # QR Code
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x43\x08" # Module size 8x8 (range: 1 - 16)
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x45\x30" # Error correction level 48 = 7%
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << [ qr_data.length + 3, 0 ].pack("v") # Data length (low byte, high byte)
    @printer << "\x31\x50\x30"   # Store QR code in memory
    @printer << qr_data          # Data QR code
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x51\x30" # Print the QR code
    # End QR Code

    @printer << "\n"
    @printer << "#{qr_data}\n"

    @printer << "\n\n"
    @printer << "\x1D\x21\x11"
    @printer << "SCAN QR\n"
    @printer << "UNTUK DOWNLOAD\n"
    @printer << "\n\n"

    @printer << "\x1D\x21\x00"
    @printer << "---------------------------\n"
    @printer << "powered by Tholee Studio\n"
    @printer << "@tholee.studio | 0895 2500 9655\n"
    @printer << "---------------------------\n"

    @printer << "\n\n\n\n\n" # Print 7 empty lines

    escpos_data = @printer.to_escpos

    # Send data to printer via cups
    IO.popen("lp -d vsc-thermal-printer", "w") do |lp|
      lp.write(escpos_data)
    end
  end

  def retry
    @session = Session.find(params[:session_id])
    @session.status = "processing"
    @session.save

    @export = @session.export.find_or_create_by(printable: true)
    @export.destroy

    AiPhotoboothJob.perform_later(@session)

    # Search printer by name
    # printer = Cups::Printer.get_destination("HiTi_P510S_2")

    # Set paper size from configuration
    # paper = @event.photobooth.paper

    # Print to printer
    # system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{@export.filename.current_path}")
  end

  private

  def set_session
    @session = Session.find(params[:session_id])
  end
end
