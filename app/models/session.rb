class Session < ApplicationRecord
  after_create_commit :broadcast_after_create
  after_update_commit { broadcast_replace_later_to :sessions_list, target: "session_#{self.id}", partial: "sessions/session", locals: { session: self } }
  after_destroy_commit :broadcast_after_destroy

  broadcasts_to ->(session) { :exports_list }

  belongs_to :event
  belongs_to :ai_theme, optional: true

  has_many :raw, dependent: :destroy
  has_many :export, dependent: :destroy

  enum :status, [ :failed, :completed, :queued, :processing, :uploading, :capturing, :pending, :downloading ]

  private

  def broadcast_after_create
    broadcast_prepend_later_to :sessions_list, target: "all_sessions", partial: "sessions/session", locals: { session: self }
    ActionCable.server.broadcast("session_count_channel_#{self.event.id}", {
      count: self.event.session.count
    })
  end

  def broadcast_after_destroy
    broadcast_remove_to :sessions_list, target: self
    ActionCable.server.broadcast("session_count_channel_#{self.event.id}", {
      count: self.event.session.count
    })
  end
end
