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

      def copy_views_and_assets
        return unless options.theme?

        copy_file \
          'app/views/layouts/thredded.html.erb',
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

      def add_dependencies
        return if no_gems_to_install? || !options.theme?

        line_in_gemfile = in_gemfile?('ruby') ? /^ruby .*$/ : /^source.*$/
        inject_into_file 'Gemfile', gems, after: line_in_gemfile
        notify_of_installation
      end

      private

      def no_gems_to_install?
        gems.chomp.empty?
      end

      def gems
        gems = "\n"
        gems << "\ngem 'bourbon'"       unless in_gemfile?('bourbon')
        gems << "\ngem 'neat'"          unless in_gemfile?('neat')
        gems << "\ngem 'bitters'"       unless in_gemfile?('bitters')
        gems << "\ngem 'sprockets-es6'" unless in_gemfile?('sprockets-es6')

        gems
      end

      def in_gemfile?(gem_name)
        gemfile.include?(gem_name)
      end

      def gemfile
        @gemfile ||= File.read('Gemfile')
      end

      def notify_of_installation
        text = "\n\tNew gems have been added to the Gemfile. Make sure to `bundle install`.\n"
        puts "\e[32m#{text}\e[0m"
      end
    end
  end
end
