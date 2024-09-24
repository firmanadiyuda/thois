class AiTheme < ApplicationRecord
  has_many :sessions

  mount_uploader :preview, AiThemePreviewUploader
end
