# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  def initialize(form:, type:, label:, data:, placeholder: "")
    @form = form
    @type = type
    @data = data
    @label = label
    @placeholder = placeholder
  end
end
