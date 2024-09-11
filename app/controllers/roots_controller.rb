# require "bundler/setup"
require "gphoto2"

class RootsController < ApplicationController
  # GET /
  def tes
    # @events = Event.all
    # puts "Hello"
    # @cameras = GPhoto2::Camera.all
  end

  def create
    # Proses data yang diterima
    # usb_data = params[:usb_device]

    # Misal: Kirim data ke libgphoto2 untuk pengolahan lebih lanjut
    # GPhoto2::Camera.open do |camera|
    # camera_config = camera.config
    # camera_config.set("iso", usb_data[:iso])
    # camera.capture(usb_data)
    # end

    render json: { status: "success" }
  end
end
