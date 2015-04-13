require 'pry'

module Thredded
  module Generators
    class ThemesGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../../spec/dummy/app/themes', __FILE__)

      def copy_all_files
        directory 'default', 'app/themes/default'
      end
    end
  end
end
