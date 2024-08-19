# frozen_string_literal: true

class TextAreaComponent < ViewComponent::Base
  def initialize(form:, label:, data:, placeholder: "", rows: 4)
    @form = form
    @data = data
    @label = label
    @placeholder = placeholder
    @rows = rows
  end
end
