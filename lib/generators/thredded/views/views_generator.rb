module Thredded
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../../app/views', __FILE__)

      def copy_view_files
        directory 'thredded', 'app/views/thredded'
      end

      def copy_layout
        copy_file \
          'layouts/thredded.html.erb',
          'app/views/layouts/thredded.html.erb'
      end
    end
  end
end
