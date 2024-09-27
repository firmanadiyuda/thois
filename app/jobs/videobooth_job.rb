class VideoboothJob < ApplicationJob
  queue_as :videobooth_queue

  sidekiq_options retry: false

  def perform(session)
    MongodbService.new(session, nil).call
      # if !session.raw.first.present?
      DownloadvideoboothService.new(session).call
    # end
    # CreatevideoboothService.new(session).call
    # UploadService.new(session).call
  end
end
