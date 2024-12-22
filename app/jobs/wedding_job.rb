class WeddingJob < ApplicationJob
  queue_as :wedding_queue

  def perform(session)
    CreategifService.new(session).call
    UploadService.new(session).call
  end
end
