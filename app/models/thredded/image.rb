module Thredded
  class Image < ActiveRecord::Base
    mount_uploader :image, ImageUploader
    validates :image, presence: true
    before_validation :save_dimensions, :save_orientation, :save_position

    private

    def save_dimensions
      if image.path
        self.width = MiniMagick::Image.open(image.path)[:width]
        self.height = MiniMagick::Image.open(image.path)[:height]
      end
    end

    def save_orientation
      if image.path
        self.orientation = (height.to_i > width.to_i) ? 'portrait' : 'landscape'
      end
    end

    def save_position
      self.position = (self._index + 1) if self.new_record? and self._index
    end
  end
end
