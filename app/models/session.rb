class Session < ApplicationRecord
  after_create_commit { broadcast_prepend_later_to :sessions_list, target: "all_sessions", partial: "sessions/session", locals: { session: self } }
  after_update_commit { broadcast_replace_later_to :sessions_list, target: "session_#{self.id}", partial: "sessions/session", locals: { session: self } }
  after_destroy_commit { broadcast_remove_to :sessions_list, target: self }

  belongs_to :event
  has_many :raw, dependent: :destroy
  has_many :export, dependent: :destroy

  enum :status, [ :failed, :completed, :pending, :processing, :uploading, :capturing ]
end
