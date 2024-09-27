class UploadService
  def initialize(session)
    # Initialize Session, Raw, and Export model
    @session = session
    @event = Event.find(@session.event_id)
    @raws = @session.raw
    @exports = @session.export
  end

  def call
    @session.status = "uploading"
    @session.save

    @image = Concurrent::Array.new
    @video = Concurrent::Array.new

    # Create a thread pool with a fixed number of threads
    thread_pool = Concurrent::FixedThreadPool.new(10)

    # Upload all Export
    # Create tasks for Export uploads
    @exports.each do |export|
      thread_pool.post do
        File.open(export.filename.current_path) do |file|
          export.cloud = file
          export.save
          @image.push({ path: export.cloud.current_path, created_at: export.created_at }) if export.filetype == "image"
          @video.push({ path: export.cloud.current_path, created_at: export.created_at }) if export.filetype == "video"
        end
      end
    end

    # Shutdown the thread pool and wait for all tasks to complete
    thread_pool.shutdown
    thread_pool.wait_for_termination

    # Sort arrays by created_at
    @image.sort_by! { |item| item[:created_at] }.reverse!
    @video.sort_by! { |item| item[:created_at] }.reverse!

    # Prepare the data to mongodb
    @update_data = {
      image: @image.map { |item| item[:path] },
      video: @video.map { |item| item[:path] }
    }

    @session.status = "completed"
    @session.save

    # Update Mongodb
    # MongodbService.new(@session, @update_data).call
  end
end
