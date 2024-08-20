class Event < ApplicationRecord
  has_one :photobooth_configuration, dependent: :destroy
  accepts_nested_attributes_for :photobooth_configuration, allow_destroy: true

  before_save :handle_configuration

  private

  def handle_configuration
    self.photobooth_configuration = nil if booth_type != 0
  end
end
