require 'pry'

module Thredded
  module Generators
    class ThemesGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../../spec/dummy/app/themes', __FILE__)

      class_option :sass_framework,
        type: :string,
        default: 'bourbon',
        desc: 'Preferred sass framework [bourbon, bootstrap, foundation]',
        hide: true

      def copy_all_files
        directory 'default', 'app/themes/default'
      end

      def inject_sass_dependencies
        return unless gems_to_inject?

        line_in_gemfile = in_gemfile?('ruby') ? /^ruby .*$/ : /^source.*$/
        notification = "\n   New gems have been added to your Gemfile. Make sure to `bundle install`.\n"

        inject_into_file 'Gemfile', gems, after: line_in_gemfile
        puts green(notification)
      end

      private

      def gems_to_inject?
        !gems.chomp.empty?
      end

      def gems
        gems = "\n"

        if options.sass_framework == 'bourbon'
          gems << "\ngem 'bourbon'"       unless in_gemfile?('bourbon')
          gems << "\ngem 'neat'"          unless in_gemfile?('neat')
          gems << "\ngem 'bitters'"       unless in_gemfile?('bitters')
          gems << "\ngem 'sprockets-es6'" unless in_gemfile?('sprockets-es6')
        end

        gems
      end

      def in_gemfile?(gem_name)
        gemfile.include?(gem_name)
      end

      def gemfile
        @gemfile ||= File.read('Gemfile')
      end

      def green(text)
        "\e[32m#{text}\e[0m"
      end
    end
  end
end
