class Export < ApplicationRecord
  belongs_to :session
  enum :filetype, [ :image, :video ]

  mount_uploader :filename, ExportUploader
  mount_uploader :compress, CompressUploader
  mount_uploader :cloud, CloudUploader
end
