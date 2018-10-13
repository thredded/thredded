# frozen_string_literal: true

module Thredded
  module IconHelper
    def inline_svg_once(filename, transform_params = {})
      id = transform_params[:id]
      fail 'Must call inline_svg_once with an id.' unless id
      return if @already_inlined_svg_ids&.include?(id)
      record_already_inlined_svg(filename, id)
      inline_svg(filename, transform_params)
    end

    private

    def record_already_inlined_svg(filename, id)
      if filename.is_a?(String) # in case it's an IO or other
        expected_id = "thredded-#{File.basename(filename, '.svg').dasherize}-icon"
        fail "Please use id: #{expected_id}" unless id == expected_id
      end
      @already_inlined_svg_ids ||= []
      @already_inlined_svg_ids << id
    end
  end
end
