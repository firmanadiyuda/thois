# frozen_string_literal: true

class RadioButtonComponent < ViewComponent::Base
  def initialize(form:, name:, options:, data: nil)
    @form = form
    @name = name
    @options = options
    @data = data
  end
end
