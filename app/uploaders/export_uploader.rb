class ExportUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env.production?
      "uploads/#{model.session.event.booth_type.to_s.underscore}/#{model.session.event.id}/export/#{model.filetype}"
    elsif Rails.env.development?
      "uploads/development/#{model.session.event.booth_type.to_s.underscore}/#{model.session.event.id}/export/#{model.filetype}"
    else
      "uploads/test/#{model.session.event.booth_type.to_s.underscore}/#{model.session.event.id}/export/#{model.filetype}"
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do 
    process :process_thumb
    def full_filename(for_file)
      "thumb/thumb_#{for_file}"
    end
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w[jpg png mp4]
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{file.filename}"
  end

  private

  # Proses transcode video ke resolusi rendah
  def process_thumb
    if model.filetype == "video"
      media = FFMPEG::Media.new(current_path)
      tmpfile = File.join(File.dirname(current_path), "thumb_#{file.filename}")
      options = {
        resolution: "270x480",
        threads: 1,
        custom: [ "-crf", 30, "-pix_fmt", "yuv420p" ]
      }

      # Atur ukuran video, di sini 320px lebar
      media.transcode(tmpfile, options) do |progress|
        progress = (progress * 100).round(2)
        ActionCable.server.broadcast("progress_channel_#{model.session.event.id}", {
          progress: progress.to_i,
          session_id: model.session.id
        })
      end 
      File.rename(tmpfile, current_path)
    else
      # process resize_to_fit: [50, 50]
    end
  end
end
