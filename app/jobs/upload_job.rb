class UploadJob < ApplicationJob
  queue_as :upload_queue

  def perform(session)
    UploadService.new(session).call
  end
end
