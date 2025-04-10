class PhotoboothsController < ApplicationController
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
      @raw = @session.raw.create(filename: file, filetype: "image")
      @raw.save

      # Delete temp file
      tempfile.close
      tempfile.unlink

      # Open recently raw image
      File.open(@raw.filename.current_path) do |file|
        # Resize image
        image = MiniMagick::Image.open(@raw.filename.current_path)
        image.resize "1920x1280"
        image.quality "90"
        tempfile = Tempfile.new([ SecureRandom.uuid, ".jpg" ])

        # Give an overlay if horizontal overlay setting true
        if @event.photobooth.use_overlay_horizontal?
          overlay = MiniMagick::Image.open(@event.photobooth.overlay_horizontal.current_path)
          result = image.composite(overlay) do |c|
            c.gravity "center"
            c.compose "Over"
          end
          result.write(tempfile.path)
        else
          image.write(tempfile.path)
        end

        # Save image to export db
        @export = @session.export.create(filename: tempfile, filetype: "image")

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
    # @sessions = @event.session.includes(:export).where(export: { filetype: "video" })
    @exports = Export.includes(:session).where(filetype: "image", printable: true, sessions: { event_id: @event.id }).order(created_at: :desc)

    # @sessions = @event.session.order(created_at: :desc)
    render layout: "gallery"
  end

  def select_photo
    begin
      CameraService.instance.stop_liveview
    rescue => e
      Rails.logger.debug e.message
    end

    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")

    id = SqidsService.new([ @session.id ]).call
    if Rails.env.production?
      @qrurl = "tholee.my.id/d/#{id}"
    elsif Rails.env.development?
      @qrurl = "tholee.my.id/development/#{id}"
    end

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

    # Simpan file ke dalam tmp folder sebelum dikirim ke job
    uploaded_file = params[:export]
    temp_path = Rails.root.join("tmp", uploaded_file.original_filename)
    File.open(temp_path, "wb") { |f| f.write(uploaded_file.read) }

    print = @event.photobooth.print?

    # Panggil job dengan path file yang sudah disimpan
    PhotoboothJob.perform_later(@event.id, temp_path.to_s, uploaded_file.original_filename, print)


    respond_to do |format|
      format.html { redirect_to event_photobooth_liveview_url(@event) }
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

    # pdf_path = Rails.root.join("tmp", "print.pdf")
    # Prawn::Document.generate(pdf_path, page_size: [ 4 * 72, 6 * 72 ], margin: 0) do |pdf|
    #   pdf.image @export.filename.current_path, fit: [ 4 * 72, 6 * 72 ]
    # end
    # system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{pdf_path}")
  end

  def retry
    @session = Session.find(params[:session_id])
    # @export = @session.export.find_or_create_by(printable: true) do |export|

    # Search printer by name
    printer = Cups::Printer.get_destination("HiTi_P510S_2")

    # Set paper size from configuration
    paper = @event.photobooth.paper

    # Print to printer
    system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{@export.filename.current_path}")
  end

  def reupload
    @session = Session.find(params[:session_id])
    UploadJob.perform_later(@session)
  end

  def delete_session
    session_id = params[:session_id]
    @session = Session.find(params[:session_id])
    @session.destroy!
  end

  private

  def set_session
    @session = Session.find(params[:session_id])
  end
end
