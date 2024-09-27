class Videobooth < ApplicationRecord
  belongs_to :event

  mount_uploader :overlay, OverlayUploader
  mount_uploader :overlay_video, OverlayVideoUploader
  mount_uploader :music, MusicUploader

  enum :quality, [ :fhd, :hd ]
end
