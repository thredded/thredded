# frozen_string_literal: true
module Thredded
  module ApplicationHelper
    include ::Thredded::UrlsHelper

    # Render the page container with the supplied block as content.
    def thredded_page(&block)
      # enable the host app to easily check whether a thredded view is being rendered:
      content_for :thredded, true
      content_for :thredded_page_content, &block
      render partial: 'thredded/shared/page'
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] html_safe link to the user
    def user_link(user)
      render partial: 'thredded/users/link', locals: { user: user }
    end

    # @param datetime [DateTime]
    # @return [String] html_safe datetime presentation
    def time_ago(datetime)
      render partial: 'thredded/shared/time_ago', locals: { datetime: datetime }
    end

    def paginate(collection, args = {})
      super(collection, args.reverse_merge(views_prefix: 'thredded'))
    end
  end
end
