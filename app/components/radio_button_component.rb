# frozen_string_literal: true

class RadioButtonComponent < ViewComponent::Base
  def initialize(form:, name:, label: nil, options:, data: nil)
    @form = form
    @name = name
    @label = label
    @options = options
    @data = data
  end
end
