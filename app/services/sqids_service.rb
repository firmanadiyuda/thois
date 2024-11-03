class SqidsService
  def initialize(data)
    @data = data
    @sqids_alphabet = Rails.application.credentials.sqids_alphabet
  end

  def call
    sqids = Sqids.new(alphabet: @sqids_alphabet)
    encoded = sqids.encode(@data)

    # if Rails.env.production?
    #   encoded = encoded
    # elsif Rails.env.development?
    #   encoded = "development/#{encoded}"
    # else
    #   encoded = "test-#{encoded}"
    # end

    encoded
  end
end
