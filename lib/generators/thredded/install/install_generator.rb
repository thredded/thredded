module Thredded
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :theme,
        type: :boolean,
        default: false,
        desc: 'Copy all thredded layout, views, and assets to parent application.'

      def set_source_paths
        @source_paths = [
          File.expand_path('../templates', __FILE__),
          File.expand_path('../../../../..', __FILE__),
        ]
      end

      def copy_initializer_file
        copy_file \
          'initializer.rb',
          'config/initializers/thredded.rb'
      end

      def add_views
        return unless options.theme?

        copy_file 'app/views/layouts/thredded.html.erb'
        directory 'app/views/thredded'
      end

      def copy_assets
        return unless options.theme?

        copy_file 'app/assets/javascripts/thredded.es6'
        directory 'app/assets/javascripts/thredded'

        copy_file 'app/assets/stylesheets/thredded.scss'
        directory 'app/assets/stylesheets/thredded'

        directory 'app/assets/images'
      end
    end
  end
end
