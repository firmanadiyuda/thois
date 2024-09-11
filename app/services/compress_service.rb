class CompressService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
    @raws = @session.raw
    @exports = @session.export
  end

  def call
    # If event is photobooth
    if @event.photobooth?
      @raws.each do |raw|
        File.open(raw.compress.current_path) do |file|
          raw.compress = file
          raw.save
        end
      end
    end

    # If event is videobooth
    if @event.videobooth?
      @exports.each do |export|
        File.open(export.compress.current_path) do |file|
          export.compress = file
          export.save
        end
      end
    end
  end
end
