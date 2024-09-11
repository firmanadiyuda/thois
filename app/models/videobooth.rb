class Videobooth < ApplicationRecord
  belongs_to :event

  mount_uploader :overlay, OverlayUploader
  mount_uploader :music, MusicUploader

  enum :quality, [ :fhd, :hd ]
end
