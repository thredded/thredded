# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe IconHelper do
    include IconHelper
    describe '#inline_svg_once' do
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

    describe '#define_svg_icons' do
      let(:svg_settings) { '<svg>settings</svg>'.html_safe } # rubocop:disable Rails/OutputSafety
      let(:svg_follow) { '<svg>follow</svg>'.html_safe } # rubocop:disable Rails/OutputSafety

      it 'works for no icons' do
        expect(define_svg_icons).to be_nil
      end
      context 'with one icon' do
        subject(:html) { define_svg_icons('thredded/settings.svg') }

        it 'wraps with definitions' do
          expect(self).to receive(:inline_svg).with('thredded/settings.svg', any_args).and_return svg_settings
          expect(html).to start_with('<div class="thredded--svg-definitions">')
          expect(html).to end_with('</div>')
          expect(html).to include(svg_settings)
        end
        context 'when already included' do
          before do
            allow(self).to receive(:inline_svg).and_return(svg_settings)
            inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')
          end

          it 'is nil' do
            expect(html).to be_nil
          end
        end
      end

      context 'with two icons' do
        subject(:html) { define_svg_icons('thredded/settings.svg', 'thredded/follow.svg') }

        it 'wraps with definitions' do
          expect(self).to receive(:inline_svg).with('thredded/settings.svg', any_args).and_return svg_settings
          expect(self).to receive(:inline_svg).with('thredded/follow.svg', any_args).and_return svg_follow
          expect(html).to start_with('<div class="thredded--svg-definitions">')
          expect(html).to end_with('</div>')
          expect(html).to include(svg_settings)
          expect(html).to include(svg_follow)
        end
        context 'when one already included' do
          before do
            allow(self).to receive(:inline_svg).once.and_return(svg_settings)
            inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')
          end

          it 'has the other one' do
            expect(self).to receive(:inline_svg).with('thredded/follow.svg', any_args).and_return svg_follow
            expect(html).not_to include(svg_settings)
            expect(html).to include(svg_follow)
          end
        end

        context 'when both already included' do
          before do
            allow(self).to receive(:inline_svg).and_return(svg_settings)
            inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')
            inline_svg_once('thredded/follow.svg', id: 'thredded-follow-icon')
          end

          it 'is nil' do
            expect(html).to be_nil
          end
        end
      end
    end
  end
end
