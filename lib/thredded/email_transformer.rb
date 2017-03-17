# frozen_string_literal: true
require 'thredded/email_transformer/onebox'

module Thredded
  # This transformer should applied to emails so that they render correctly in the email clients.
  #
  # For example, if you use roadie, you can configure it to use the transformer in the initializer:
  #
  #     # config/initializers/roadie.rb
  #     Rails.application.config.roadie.before_transformation = Thredded::EmailTransformer
  #
  module EmailTransformer
    mattr_accessor :transformers
    self.transformers = [Onebox]

    # @param doc [Nokogiri::HTML::Document]
    def self.call(doc)
      transformers.each { |transformer| transformer.call(doc) }
    end
  end
end
