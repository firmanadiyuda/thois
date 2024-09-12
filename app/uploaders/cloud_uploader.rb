class CloudUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env.production?
      "events/#{model.session.event.id}/#{model.filetype}"
    elsif Rails.env.development?
      "events/development/#{model.session.event.id}/#{model.filetype}"
    else
      "events/test/#{model.session.event.id}/#{model.filetype}"
    end
  end

  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider:              "AWS",
      aws_access_key_id:     Rails.application.credentials.storj.access_key_id,
      aws_secret_access_key: Rails.application.credentials.storj.secret_access_key,
      region:                "ap",
      endpoint:              Rails.application.credentials.storj.endpoint,
      path_style:            false
    }
    config.fog_directory  = Rails.application.credentials.storj.bucket
    config.fog_public     = true
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
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

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
end
