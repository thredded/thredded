require 'spec_helper'

module Thredded
  describe Attachment do
    it { should belong_to(:post) }
    it { should validate_presence_of(:attachment) }

    describe '.filename' do
      it 'should return a filaname from a path' do
        image = build_stubbed(:attachment)
        expect(image.filename).to eq('img.png')
      end
    end
  end
end
