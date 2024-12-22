class WeddingsController < ApplicationController
  def process_photo
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")

    @session.status = "processing"
    @session.save

    qr(@session.id)

    cd = @event.wedding.cam_dir
    total_photo = params[:total]

    GPhoto2::Camera.first do |camera|
      # Get camera root directory
      cam_dir = camera/""
      cam_dir = cam_dir.folders

      # Get storage root directory
      storage_dir = camera/"#{cam_dir.first.name}/#{cd}"
      all_files = storage_dir.files
      jpg_files = all_files.select { |file| File.extname(file.name).downcase == ".jpg" }

      puts "#{storage_dir.path} (#{jpg_files.size} files)"
      selected_files = jpg_files.last(Integer(total_photo))

      selected_files.each do |file|
        info = file.info
        name = file.name
        puts name

        # Build a temporary file for the decoded base64 image
        tempfile = Tempfile.new([ "image", ".jpg" ])
        tempfile.binmode
        tempfile.write(file.data)
        tempfile.rewind

        # Simulate an file field form
        file = ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
          filename: "#{SecureRandom.uuid}.jpg",
          type: "image/jpg"
        )

        # Save image to raw db
        @raw = @session.raw.create(filename: file, filetype: "image")
        @raw.save


        # Open recently raw image
        File.open(@raw.filename.current_path) do |file|
          # Resize image
          image = MiniMagick::Image.open(@raw.filename.current_path)
          image.resize "1920x1280"
          image.quality "90"
          tempfile = Tempfile.new([ SecureRandom.uuid, ".jpg" ])

          # Give an overlay if horizontal overlay setting true
          if @event.wedding.use_overlay?
            overlay = MiniMagick::Image.open(@event.wedding.overlay.current_path)
            result = image.composite(overlay) do |c|
              c.gravity "center"
              c.compose "Over"
            end
            result.write(tempfile.path)
          else
            image.write(tempfile.path)
          end


          @export = @session.export.create(filename: tempfile, filetype: "image")
          @export.save
        end

        # Delete temp file
        tempfile.close
        tempfile.unlink
      end
    end

    WeddingJob.perform_later(@session)
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

  def finish
    @event = Event.find(params[:event_id])
    @session = @event.session.find_or_create_by(status: "capturing")

    uploaded_image = params[:export].path

    # Resize the image using MiniMagick
    image = MiniMagick::Image.open(uploaded_image)
    image.resize "1200x1800"

    resized_image_path = Rails.root.join("tmp", "#{params[:export].original_filename}")
    image.write(resized_image_path)

    # @export = @session.export.create(filename: params[:export], filetype: "image")
    # Create new export, containing printable image
    @export = @session.export.find_or_create_by(printable: true) do |export|
      export.filename = params[:export]
      # export.filename = File.open(resized_image_path)
      export.filetype = "image"
    end

    @session.status = "processing"
    @session.save

    @new_session = @event.session.find_or_create_by(status: "capturing")

    # Dispatch Photobooth Job
    PhotoboothJob.perform_later(@session)

    # Print image if print configuration set to true
    if @event.photobooth.print?
      # Search printer by name
      printer = Cups::Printer.get_destination("HiTi_P510S_2")

      # Set paper size from configuration
      paper = @event.photobooth.paper

      # Print to printer
      system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{@export.filename.current_path}")
      #
      # pdf_path = Rails.root.join("tmp", "print.pdf")
      # Prawn::Document.generate(pdf_path, page_size: [ 4 * 72, 6 * 72 ], margin: 0) do |pdf|
      #   pdf.image @export.filename.current_path, fit: [ 4 * 72, 6 * 72 ]
      # end
      # system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{pdf_path}")
    end

    File.delete(resized_image_path) if File.exist?(resized_image_path)

    respond_to do |format|
      format.html { redirect_to event_photobooth_liveview_url(@event) }
    end
  end

  def reupload
    @session = Session.find(params[:session_id])
    UploadJob.perform_later(@session)
  end

  def operator
    @event = Event.find(params[:event_id])
    # @session = @event.session.find_or_create_by(status: "capturing")
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
