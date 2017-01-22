# frozen_string_literal: true
module Thredded
  module RenderPreview
    protected

    def render_preview
      if request.xhr?
        render layout: false
      else
        @preview_content = render_to_string(layout: false)
        render template: 'thredded/shared/preview'
      end
    end
  end
end
