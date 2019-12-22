# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe IconHelper do
    include IconHelper
    # rubocop:disable Rails/OutputSafety
    let(:settings_svg) { '<svg id="thredded-settings-icon">settings</svg>'.html_safe }
    let(:follow_svg) { '<svg id="thredded-follow-icon">follow</svg>'.html_safe }
    # rubocop:enable Rails/OutputSafety

    describe '#inline_svg_once' do
      it 'calls inline_svg' do
        expect(self).to receive(:inline_svg_tag).and_return settings_svg
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon'))
          .to eq(settings_svg)
      end

      it 'only inlines once' do
        expect(self).to receive(:inline_svg_tag).once.and_return(settings_svg)
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')).to eq(settings_svg)
        expect(inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')).to be_nil
      end

      it 'requires a specific id based on filename' do
        expect { inline_svg_once('thredded/much_ado_about_whatever.svg', id: 'whatever-i-feel-like') }
          .to raise_error(/thredded-much-ado-about-whatever-icon/)
      end
    end

    describe '#define_svg_icons' do
      it 'works for no icons' do
        expect(define_svg_icons).to be_nil
      end
      context 'with one icon' do
        subject(:html) { define_svg_icons('thredded/settings.svg') }

        it 'wraps with definitions' do
          expect(self).to receive(:inline_svg_tag).with('thredded/settings.svg', any_args).and_return settings_svg
          expect(html).to start_with('<div class="thredded--svg-definitions">')
          expect(html).to end_with('</div>')
          expect(html).to include(settings_svg)
        end
        context 'when already included' do
          before do
            allow(self).to receive(:inline_svg_tag).and_return(settings_svg)
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
          expect(self).to receive(:inline_svg_tag).with('thredded/settings.svg', any_args).and_return settings_svg
          expect(self).to receive(:inline_svg_tag).with('thredded/follow.svg', any_args).and_return follow_svg
          expect(html).to start_with('<div class="thredded--svg-definitions">')
          expect(html).to end_with('</div>')
          expect(html).to include(settings_svg)
          expect(html).to include(follow_svg)
        end
        context 'when one already included' do
          before do
            allow(self).to receive(:inline_svg_tag).once.and_return(settings_svg)
            inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')
          end

          it 'has the other one' do
            expect(self).to receive(:inline_svg_tag).with('thredded/follow.svg', any_args).and_return follow_svg
            expect(html).not_to include(settings_svg)
            expect(html).to include(follow_svg)
          end
        end

        context 'when both already included' do
          before do
            allow(self).to receive(:inline_svg_tag).and_return(settings_svg)
            inline_svg_once('thredded/settings.svg', id: 'thredded-settings-icon')
            inline_svg_once('thredded/follow.svg', id: 'thredded-follow-icon')
          end

          it 'is nil' do
            expect(html).to be_nil
          end
        end
      end
    end

    describe '#shared_inline_svg' do
      before do
        allow(self).to receive(:inline_svg_tag).and_return(settings_svg)
      end

      it 'outputs definition' do
        html = shared_inline_svg('thredded/settings.svg')
        expect(html).to include('<div class="thredded--svg-definitions">')
        expect(html).to include('id="thredded-settings-icon"')
        expect(html).to include(settings_svg)
      end
      it 'outputs use' do
        expect(shared_inline_svg('thredded/settings.svg'))
          .to include('<svg><use xlink:href="#thredded-settings-icon"></use></svg>')
      end
      it 'passes through args' do
        html = shared_inline_svg('thredded/settings.svg', class: 'flong')
        expect(html).to include('<svg class="flong">')
      end
    end
  end
end
