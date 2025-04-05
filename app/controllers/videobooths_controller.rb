require "escpos" # Pastikan modul helpers di-load
require "escpos/helpers" # Pastikan modul helpers di-load

class VideoboothsController < ApplicationController
  def gallery
    @event = Event.find(params[:event_id])
    @sessions = @event.session.order(created_at: :desc)
    render layout: "liveview"
  end

  def preprocess_video
    event_id = params[:event_id]
    @event = Event.find(event_id)
    @session = @event.session.create(status: "pending", gopro_counter: @event.videobooth.counter)
    @session.save
    qr(@session.id)
    increment_counter
  end

  def process_video
    event_id = params[:event_id]
    @event = Event.find(event_id)
    session_id = params[:session_id]
    @session = Session.find(session_id)

    @session.status = "queued"
    @session.save

    VideoboothJob.perform_later(@session)
  end

  def increment_counter
    event_id = params[:event_id]
    event = Event.find(event_id)
    videobooth = event.videobooth
    videobooth.counter = videobooth.counter + 1
    videobooth.save
    ActionCable.server.broadcast("gopro_counter_channel_#{event.id}", {
      counter: videobooth.counter
    })
  end

  def decrement_counter
    event_id = params[:event_id]
    event = Event.find(event_id)
    videobooth = event.videobooth
    videobooth.counter = videobooth.counter - 1
    videobooth.save
    ActionCable.server.broadcast("gopro_counter_channel_#{event.id}", {
      counter: videobooth.counter
    })
  end

  def increment_session_counter
    session_id = params[:session_id]
    session = Session.find(session_id)
    session.gopro_counter = session.gopro_counter + 1
    session.save
  end

  def decrement_session_counter
    session_id = params[:session_id]
    session = Session.find(session_id)
    session.gopro_counter = session.gopro_counter - 1
    session.save
  end

  def print_qr
    session_id = params[:session_id]
    qr(session_id)
  end

  def qr(session_id)
    @session = Session.find(session_id)
    id = SqidsService.new([ @session.id ]).call

    @printer = Escpos::Printer.new

    # Normal size (1x1): \x1D\x21\x00
    # 2x width and 2x height: \x1D\x21\x11
    # 3x width and 3x height: \x1D\x21\x22
    # 4x width and 4x height: \x1D\x21\x33

    qr_data = "https://tholee.my.id/d/#{id}"

    @printer << "\n\n\n"  # Print 3 empty lines
    @printer << "\x1B\x61\x01" # ESC a 1 -> Align center

    # QR Code
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x43\x08" # Module size 8x8 (range: 1 - 16)
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x45\x30" # Error correction level 48 = 7%
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << [ qr_data.length + 3, 0 ].pack("v") # Data length (low byte, high byte)
    @printer << "\x31\x50\x30"   # Store QR code in memory
    @printer << qr_data          # Data QR code
    @printer << "\x1D\x28\x6B"   # GS ( k
    @printer << "\x03\x00\x31\x51\x30" # Print the QR code
    # End QR Code

    @printer << "\n"
    @printer << "#{qr_data}\n"

    @printer << "\n\n"
    @printer << "\x1D\x21\x11"
    @printer << "SCAN QR\n"
    @printer << "UNTUK DOWNLOAD\n"
    @printer << "\n\n"

    @printer << "\x1D\x21\x00"
    @printer << "---------------------------\n"
    @printer << "powered by Tholee Studio\n"
    @printer << "@tholee.studio | 0895 2500 9655\n"
    @printer << "---------------------------\n"

    @printer << "\n\n\n\n\n" # Print 7 empty lines

    escpos_data = @printer.to_escpos

    # Send data to printer via cups
    IO.popen("lp -d vsc-thermal-printer", "w") do |lp|
      lp.write(escpos_data)
    end
  end

  def delete_session
    session_id = params[:session_id]
    @session = Session.find(params[:session_id])
    @session.destroy!
  end

  def reupload
    @session = Session.find(params[:session_id])
    UploadJob.perform_later(@session)
  end

  def gallery
    @event = Event.find(params[:event_id])
    # @sessions = @event.session.includes(:export).where(export: { filetype: "video" })
    @exports = Export.includes(:session).where(filetype: "video", sessions: { event_id: @event.id }).order(created_at: :desc)

    # @sessions = @event.session.order(created_at: :desc)
    render layout: "gallery"
  end

  private

  def set_session
    @session = Session.find(params[:session_id])
  end
end
