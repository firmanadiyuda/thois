class Raw < ApplicationRecord
  belongs_to :session
  enum :filetype, [ :image, :video ]

  mount_uploader :filename, RawUploader
  mount_uploader :compress, CompressUploader
  mount_uploader :cloud, CloudUploader
end
