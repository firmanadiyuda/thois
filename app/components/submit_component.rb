# frozen_string_literal: true

class SubmitComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end
end
