module Thredded
  class Attachment < ActiveRecord::Base
    belongs_to :post, touch: true
    validates_presence_of :attachment
    mount_uploader :attachment, Thredded::AttachmentUploader
    before_save :update_attachment_attributes
    belongs_to :post

    def cache_dir
      "#{Rails.root}/tmp/uploads"
    end

    def filename
      File.basename(attachment.path)
    end

    def update_attachment_attributes
      if attachment.present? && attachment_changed?
        self.content_type = attachment.file.content_type
        self.file_size = attachment.file.size
      end
    end
  end
end
