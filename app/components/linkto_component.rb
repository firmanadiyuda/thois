# frozen_string_literal: true

class LinktoComponent < ViewComponent::Base
  def initialize(text: "", path:)
    @text = text
    @path = path
  end
end
