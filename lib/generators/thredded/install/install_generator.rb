module Thredded
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :theme,
                   type:    :boolean,
                   default: false,
                   desc:    'Copy all thredded layout, views, and assets to parent application.'

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

      def copy_views_and_assets
        return unless options.theme?

        copy_file \
          'app/views/layouts/thredded/application.html.erb',
          'vendor/views/layouts/thredded.html.erb'

        directory \
          'app/views/thredded',
          'vendor/views/thredded'

        copy_file \
          'app/assets/javascripts/thredded.es6',
          'vendor/assets/javascripts/thredded.es6'

        directory \
          'app/assets/javascripts/thredded',
          'vendor/assets/javascripts/thredded'

        copy_file \
          'app/assets/stylesheets/thredded.scss',
          'vendor/assets/stylesheets/thredded.scss'

        directory \
          'app/assets/stylesheets/thredded',
          'vendor/assets/stylesheets/thredded'

        directory \
          'app/assets/images/thredded',
          'vendor/assets/images/thredded'
      end
    end
  end
end
