# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe IconHelper do
    include IconHelper
    describe 'inline_svg_once' do
      let(:svg) { '<svg>lovely-jubbly</svg>' }

      it 'calls inline_svg' do
        expect(self).to receive(:inline_svg).and_return svg
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon'))
          .to eq(svg)
      end

      it "blows up if doesn't have an id attr" do
        expect(self).not_to receive(:inline_svg)
        expect { inline_svg_once('thredded/settings.svg') }.to raise_error(/\binline_svg_once.*id\b/)
      end

      it 'only inlines once' do
        expect(self).to receive(:inline_svg).once.and_return(svg)
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')).to eq(svg)
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')).to be_nil
      end

      it 'requires a specific id based on filename' do
        expect { inline_svg_once('thredded/much_ado_about_whatever.svg', id: 'whatever-i-feel-like') }
          .to raise_error(/thredded-much-ado-about-whatever-icon/)
      end
    end
  end
end
