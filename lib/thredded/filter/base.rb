module Thredded
  module Filter
    module Base
      Filters = []

      def filters; Filters; end

      def filtered_content
        self.content
      end
    end
  end
end
