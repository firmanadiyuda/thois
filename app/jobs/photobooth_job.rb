class PhotoboothJob < ApplicationJob
  queue_as :photobooth_queue

  def perform(session)
    # MongodbService.new(session, nil).call
    CreategifService.new(session).call
    UploadService.new(session).call
  end
end
