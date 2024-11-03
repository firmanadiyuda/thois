class Export < ApplicationRecord
  after_create_commit :broadcast_type
  after_update_commit { broadcast_replace_later_to :export_list, target: "export_#{self.id}", partial: "exports/export", locals: { export: self } }
  after_destroy_commit { broadcast_remove_to :export_list, target: self }

  belongs_to :session
  enum :filetype, [ :image, :video ]

  mount_uploader :filename, ExportUploader
  mount_uploader :compress, CompressUploader
  mount_uploader :cloud, CloudUploader

  private

  def broadcast_type
    if self.session.event.booth_type == "photobooth"
      if self.filetype == "video"
        broadcast_prepend_later_to :export_list, target: "all_exports", partial: "exports/export", locals: { export: self }
      end
    end
    if self.session.event.booth_type == "videobooth"
      broadcast_prepend_later_to :export_list, target: "all_exports", partial: "exports/export", locals: { export: self }
    end
  end
end
