class VideoboothJob < ApplicationJob
  queue_as :videobooth_queue

  sidekiq_options retry: false

  def perform(session)
    DownloadvideoboothService.new(session).call
  end
end
