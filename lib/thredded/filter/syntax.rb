require 'coderay'
require 'htmlentities'

module Thredded
  module Filter
    module Syntax
      def filtered_content
        content = String.new(super)
        content = HTMLEntities.new.decode(content)

        content = content.to_s
          .gsub(/\<pre\>\<code( lang="(.+?)")?\>(.+?)\<\/code\>\<\/pre\>/m) do
          filter = $2.nil? ? :ruby : $2.to_sym
          temp_code = $3.gsub(/&quot;/, '"').
            gsub(/&#39;/,"'").
            gsub(/&amp;/, "&").
            gsub(/&gt;/, ">").
            gsub(/&lt;/, "<").
            gsub(/\<br \/\>/, "")

          ::CodeRay.scan(temp_code, filter).div(css: :class)
        end

        content.html_safe
      end
    end
  end
end
