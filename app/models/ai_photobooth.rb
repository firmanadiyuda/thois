class AiPhotobooth < ApplicationRecord
  belongs_to :event
  mount_uploader :overlay, OverlayUploader

  enum :paper, [ "p6x4", "p6x4_split" ]
end
