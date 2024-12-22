class Wedding < ApplicationRecord
  belongs_to :event

  mount_uploader :overlay, OverlayUploader
end
