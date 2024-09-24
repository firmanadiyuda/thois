class GenerateAiService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
    @raws = @session.raw
    @ai_theme = AiTheme.find(@session.ai_theme_id)
  end

  def call
    @raw = @raws.first

    image = MiniMagick::Image.open(@raw.filename.current_path)
    image.auto_orient
    # image.resize "1280x1920"
    # image.crop "1152x1920+64+0"
    image.quality "50"
    image.strip

    base64_image = Base64.encode64(image.to_blob)

    begin
      response = Faraday.post(@event.ai_photobooth.ai_api) do |req|
        req.options.timeout = 3600

        req.headers["Content-Type"] = "application/json"
        req.body = {
          prompt: @ai_theme.prompt,
          negative_prompt: @ai_theme.negative_prompt,
          styles: JSON.parse(@ai_theme.styles),
          image: base64_image
        }.to_json
      end
      handle_response(response)
    rescue => e
      @session.status = "failed"
      @session.save
      raise "Error"
    end
  end

  private

  def handle_response(response)
    if response.success?
      { status: response.status, body: response.body }
      # Define a filename
      uuid = SecureRandom.uuid

      json_response = JSON.parse(response.body)

      # Rails.logger.debug(response.body)
      generated_image = json_response["image"]

      # Decode image from base64
      decoded_image = Base64.decode64(generated_image)

      # Build a temporary file for the decoded base64 image
      tempfile = Tempfile.new([ "raw_ai", ".png" ])
      tempfile.binmode
      tempfile.write(decoded_image)
      tempfile.rewind

      # Load the image using MiniMagick
      image = MiniMagick::Image.open(tempfile.path)
      # image.resize "1152x1920"
      image.resize "1200x2000"
      image.gravity "center"
      image.crop "1200x1800+0+100"

      # Load the overlay image
      overlay = MiniMagick::Image.open(@event.ai_photobooth.overlay.current_path)

      # Apply the overlay
      result = image.composite(overlay) do |c|
        c.gravity "center"
        c.compose "Over"
      end

      # Save the resulting image to a new temporary file
      output_tempfile = Tempfile.new([ "overlay_ai", ".png" ])
      result.write(output_tempfile.path)

      # Simulate an file field form
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: output_tempfile,
        filename: "#{uuid}.png",
        type: "image/png"
      )

      @export = @session.export.find_or_create_by(printable: true) do |export|
        export.filename = file
        export.filetype = "image"
      end

      tempfile.close
      tempfile.unlink
      output_tempfile.close
      output_tempfile.unlink
    else
      @session.status = "failed"
      @session.save
      { error: "Request failed with status #{response.status}", body: response.body }
    end
  end
end
