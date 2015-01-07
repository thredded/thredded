module Thredded
  class Image < ActiveRecord::Base
    mount_uploader :image, ImageUploader
    validates :image, presence: true
    before_validation :save_dimensions, :save_orientation, :save_position
    belongs_to :post

    private

    def save_dimensions
      return unless image.path

      self.width = MiniMagick::Image.open(image.path)[:width]
      self.height = MiniMagick::Image.open(image.path)[:height]
    end

    def save_orientation
      return unless image.path

      self.orientation = (height.to_i > width.to_i) ? 'portrait' : 'landscape'
    end

    def save_position
      self.position = (_index + 1) if new_record? && _index
    end
  end
end
