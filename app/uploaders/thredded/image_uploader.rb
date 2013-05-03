require 'carrierwave/processing/mini_magick'

module Thredded
  class ImageUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    storage :file

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def extension_white_list
      %w(jpg jpeg gif png)
    end
  end
end
