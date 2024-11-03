# frozen_string_literal: true

class ButtontoComponent < ViewComponent::Base
  def initialize(show_spinner: true, path: nil, theme: 'primary', size: 'md', confirm: nil, method: "post")
    if size == 'sm'
      @size = 'px-3 py-1'
    elsif size == 'md'
      @size = 'px-5 py-2.5'
    end

    if theme == 'primary'
      @class = "text-black from-zinc-200 via-zinc-300 to-zinc-400 hover:shadow-zinc-500/80 focus:ring-zinc-800 shadow-zinc-800/80 #{@size}" 
    elsif theme == 'alternative'
      @class = "text-black from-cyan-400 via-cyan-500 to-cyan-600 hover:shadow-cyan-400/50 focus:ring-cyan-800 shadow-cyan-800/50 #{@size}" 
    elsif theme == 'secondary'
      @class = "text-white from-blue-500 via-blue-600 to-blue-700 hover:shadow-blue-400/50 focus:ring-blue-800 shadow-blue-800/50 #{@size}" 
    elsif theme == 'danger'
      @class = "text-white from-red-600 via-red-700 to-red-800 hover:shadow-red-500/50 focus:ring-red-800 shadow-red-800/50 #{@size}" 
    elsif theme == 'warning'
      @class = "text-black from-yellow-400 via-yellow-500 to-yellow-600 hover:shadow-yellow-500/50 focus:ring-yellow-800 shadow-yellow-800/50 #{@size}" 
    end

    @confirm = confirm
    @method = method
    @show_spinner = show_spinner
    @path = path
  end
end
