class AiPhotoboothJob < ApplicationJob
  queue_as :ai_photobooth_queue

  sidekiq_options retry: false

  def perform(session)
    MongodbService.new(session, nil).call
    GenerateAiService.new(session).call
    UploadService.new(session).call
  end
end
