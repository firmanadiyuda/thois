class CameraController < ApplicationController
  require "gphoto2"

  def capture
  end

  def live
    GPhoto2::Camera.first do |camera|
      # Get camera root directory
      cam_dir = camera/""
      cam_dir = cam_dir.folders

      # Get storage root directory
      storage_dir = camera/"#{cam_dir.first.name}/DCIM/100CANON"
      # storage_dir = storage_dir.files
      all_files = storage_dir.files
      jpg_files = all_files.select { |file| File.extname(file.name).downcase == ".jpg" }

      # storage_dir.files.map(&:name)

      puts "#{storage_dir.path} (#{jpg_files.size} files)"
      selected_files = jpg_files.last(7)

      selected_files.each do |file|
        info = file.info
        name = file.name
        puts name
        file.save
      end
    end
  end

  def preview
  end

  def control
  end
end
