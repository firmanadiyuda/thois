class SqidsService
  def initialize(data)
    @data = data
    @sqids_alphabet = Rails.application.credentials.sqids_alphabet
  end

  def call
    sqids = Sqids.new(alphabet: @sqids_alphabet)
    sqids.encode(@data)
  end
end
