require 'carrierwave/processing/mini_magick'

module Thredded
  class AttachmentUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    storage :file

    def store_dir
      "uploads/#{mounted_as}/#{model.id}"
    end

    version :thumb, if: :image? do
      process :resize_to_fit => [90, 90]
    end

    version :mobile, if: :image? do
      process :resize_to_limit => [480, 2000]
    end

    def extension_white_list
      %w(jpg jpeg gif png pdf zip tgz txt)
    end

    protected

    def image?(new_file)
      new_file.content_type.include? 'image'
    end
  end
end
