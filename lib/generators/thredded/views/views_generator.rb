module Thredded
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc "Thredded views"
      source_root File.expand_path('../templates', __FILE__)
    end
  end
end
