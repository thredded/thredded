# frozen_string_literal: true

require 'thredded/email_transformer/onebox'
require 'thredded/email_transformer/spoiler'

module Thredded
  # This transformer should applied to emails so that they render correctly in the email clients.
  #
  # For example, if you use roadie, you can configure it to use the transformer in the initializer:
  #
  #     # config/initializers/roadie.rb
  #     Rails.application.config.roadie.before_transformation = Thredded::EmailTransformer
  #
  module EmailTransformer
    class << self
      attr_accessor :transformers
    end
    @transformers = [Onebox, Spoiler]

    # @param dom [Nokogiri::HTML::Document]
    def self.call(doc, *)
      transformers.each { |transformer| transformer.call(doc) }
    end
  end
end
