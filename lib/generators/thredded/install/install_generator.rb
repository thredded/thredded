# frozen_string_literal: true
module Thredded
  module Generators
    class InstallGenerator < Rails::Generators::Base
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
    end
  end
end
