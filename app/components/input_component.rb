# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  def initialize(form:, label:, data:, placeholder:)
    @form = form
    @data = data
    @label = label
    @placeholder = placeholder
  end
end
