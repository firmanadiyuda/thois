class Event < ApplicationRecord
  after_create_commit { broadcast_prepend_later_to :events_list, target: "all_events", partial: "events/event", locals: { event: self } }
  after_update_commit { broadcast_replace_later_to :events_list, target: "event_#{self.id}", partial: "events/event", locals: { event: self } }
  after_destroy_commit { broadcast_remove_to :events_list, target: self }

  has_one :photobooth, dependent: :destroy
  has_one :ai_photobooth, dependent: :destroy
  has_one :videobooth, dependent: :destroy
  has_many :session, dependent: :destroy

  enum :booth_type, [ :photobooth, :videobooth, :ai_photobooth ]

  accepts_nested_attributes_for :photobooth, allow_destroy: true
  accepts_nested_attributes_for :videobooth, allow_destroy: true
  accepts_nested_attributes_for :ai_photobooth, allow_destroy: true
  # accepts_nested_attributes_for :session, allow_destroy: true

  before_save :handle_configuration

  private

  def handle_configuration
    # photobooth.destroy if not photobooth?
    # videobooth.destroy if not videobooth?
  end
end
