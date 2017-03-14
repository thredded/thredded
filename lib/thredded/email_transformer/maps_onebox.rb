# frozen_string_literal: true
require 'thredded/email_transformer/base'
module Thredded
  module EmailTransformer
    # Replaces Google Maps iframes with links.
    class MapsOnebox < Base
      def call
        doc.css('.maps-onebox').each do |maps_onebox|
          url = maps_onebox.at('iframe')['src'].to_s
          maps_onebox.swap paragraph(anchor(url.sub('&output=embed', '')))
        end
      end
    end
  end
end
