# frozen_string_literal: true
module Thredded
  class BaseMailer < ActionMailer::Base
    helper ::Thredded::UrlsHelper

    protected

    # Find a record by ID, or return the passed record.
    # @param [Class<ActiveRecord::Base>] klass
    # @param [Integer, String, klass] id_or_record
    # @return [klass]
    def find_record(klass, id_or_record)
      # Check by name because in development the Class might have been reloaded after id was initialized
      id_or_record.class.name == klass.name ? id_or_record : klass.find(id_or_record)
    end
  end
end
