class CreategifService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
    @raws = @session.raw
  end

  def call
    # Define a filename
    uuid = SecureRandom.uuid

    # Define gif duration
    duration = 15

    # Set a compress ratio,
    # bigger means smaller size
    crf = 30

    # Define repeat count
    repeat_count = duration - 1

    # Create temporary directory
    temp_dir = Rails.root.join("tmp", "gif/#{uuid}")
    FileUtils.mkdir_p(temp_dir)

    # Create file symlink from raw image to temporary directory,
    # named sequential to create gif
    file_index = 1
    @raws.each do |raw_image|
      image_path = raw_image.filename.path
      temp_file_path = temp_dir.join("img_%03d.jpg" % file_index)
      FileUtils.ln_s(image_path, temp_file_path)
      file_index += 1
    end

    # Create temporary directory for exported gif
    gif_temp = Rails.root.join("tmp", "gif/#{uuid}/#{uuid}.mp4")

    if @event.booth_type == "photobooth"
      overlay_horizontal = @event.photobooth.overlay_horizontal.current_path

      # Preparing gif creation
      if @event.photobooth.use_overlay_horizontal?
        @filter_complex = "[0:v]loop=#{repeat_count}:size=#{@raws.count},setpts=N/#{@raws.count}/TB,scale=1080:720[e];[1]scale=1080:720[ov];[e][ov]overlay=0:0"
        @custom_parameter = [ "-i", overlay_horizontal, "-filter_complex", @filter_complex, "-pix_fmt", "yuv420p" ]
      else
        @filter_complex = "[0:v]loop=#{repeat_count}:size=#{@raws.count},setpts=N/#{@raws.count}/TB,scale=1080:720"
        @custom_parameter = [ "-filter_complex", @filter_complex, "-pix_fmt", "yuv420p" ]
      end
    else

      overlay = @event.wedding.overlay.current_path
      if @event.wedding.use_overlay?
        @filter_complex = "[0:v]loop=#{repeat_count}:size=#{@raws.count},setpts=N/#{@raws.count}/TB,scale=1080:720[e];[1]scale=1080:720[ov];[e][ov]overlay=0:0"
        @custom_parameter = [ "-i", overlay, "-filter_complex", @filter_complex, "-pix_fmt", "yuv420p" ]
      else
        @filter_complex = "[0:v]loop=#{repeat_count}:size=#{@raws.count},setpts=N/#{@raws.count}/TB,scale=1080:720"
        @custom_parameter = [ "-filter_complex", @filter_complex, "-pix_fmt", "yuv420p" ]
      end
    end

    gif_transcoder = FFMPEG::Transcoder.new(
      temp_dir.join("img_%03d.jpg").to_s,
      gif_temp.to_s,
      {
      threads: 2,
      custom: @custom_parameter
      }
    )
    gif = gif_transcoder.run

    # Open gif temporary file, and save it to export model
    File.open(gif.path) do |file|
      export = @session.export.create(filetype: "video")
      export.filename = file
      export.save
    end

    # Delete temporary directory
    FileUtils.rm_rf(temp_dir)
  end
end
