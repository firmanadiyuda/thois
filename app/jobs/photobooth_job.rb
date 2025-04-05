class PhotoboothJob < ApplicationJob
  queue_as :photobooth_queue

  def perform(event_id, uploaded_image_path, original_filename, print)
    event = Event.find(event_id)
    session = event.session.find_or_create_by(status: "capturing")

    return unless File.exist?(uploaded_image_path) # Pastikan file ada sebelum diproses

    # Resize the image using MiniMagick
    image = MiniMagick::Image.open(uploaded_image_path)
    image.density(300)

    width, height = image.dimensions
    if height > width
      image.resize "1200x1800"
    else
      image.resize "1800x1200"
    end

    resized_image_path = Rails.root.join("tmp", original_filename)
    image.write(resized_image_path)

    export = session.export.create(filename: File.open(resized_image_path), filetype: "image")

    # Add margin
    printable_image = MiniMagick::Image.open(export.filename.current_path)
    printable_image.density(300)
    margin = 20
    new_width = printable_image.width + (margin * 2)
    new_height = printable_image.height + (margin * 2)

    printable_image.combine_options do |c|
      c.gravity "center"
      c.background "white"
      c.extent "#{new_width}x#{new_height}"
    end

    printable_filename = "printable_#{original_filename}"
    printable_image_path = Rails.root.join("tmp", printable_filename)
    printable_image.write(printable_image_path)

    export = session.export.find_or_create_by(printable: true) do |exp|
      exp.filename = File.open(printable_image_path)
      exp.filetype = "image"
    end

    session.status = "processing"
    session.save

    event.session.find_or_create_by(status: "capturing")

    # Dispatch Photobooth Job
    PhotoboothJob.perform_later(session)

    # Print image if needed
    if print
      printer = Cups::Printer.get_destination("HiTi_P510S_2")
      paper = event.photobooth.paper
      system("lp -d #{printer.name} -o PageSize=#{paper.capitalize} -o scaling=20 #{export.filename.current_path}")
    end

    # Hapus file setelah selesai diproses
    File.delete(uploaded_image_path) if File.exist?(uploaded_image_path)
    File.delete(resized_image_path) if File.exist?(resized_image_path)
    File.delete(printable_image_path) if File.exist?(printable_image_path)

    # MongodbService.new(session, nil).call
    CreategifService.new(session).call
    UploadService.new(session).call
  end
end
