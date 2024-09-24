class MongodbService
  def initialize(session, data)
    # Initialize Session and Event model
    @session = session
    @event = Event.find(@session.event_id)

    # Updated data
    @data = data
  end

  def call
    id = SqidsService.new([ @session.id ]).call

    update_data = {
      event: {
        id: @event.id,
        name: @event.name
      }
    }

    update_data[:file] = @data

    response = Faraday.post("https://ap-southeast-1.aws.data.mongodb-api.com/app/data-ofqhx/endpoint/data/v1/action/updateOne") do |req|
      req.headers["Content-Type"] = "application/json"
      req.headers["apiKey"] = Rails.application.credentials.db.cloud.apikey
      req.body = {
        dataSource: "Cluster0",
        database: "tholee-database",
        collection: "tholee-collection",
        filter: {
          id: id
        },
        update: {
          "$set" => update_data
        },
        upsert: true
      }.to_json
    end

    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      { status: response.status, body: response.body }
    else
      { error: "Request failed with status #{response.status}", body: response.body }
    end
  end
end
