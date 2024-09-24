class AiService
  def initialize(session)
    # Initialize Session and Raw model
    @session = session
    @event = Event.find(@session.event_id)
    @raws = @session.raw
    @exports = @session.export
  end

  def call
  end
end
