class Photobooth < ApplicationRecord
  belongs_to :event
  mount_uploader :overlay, OverlayUploader
  mount_uploader :overlay_horizontal, OverlayHorizontalUploader

  enum :paper, [ "p6x4", "p6x4_split" ]
end
