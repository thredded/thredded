# frozen_string_literal: true

module Thredded
  class PrivatePostPermalinksController < Thredded::ApplicationController
    before_action :thredded_require_login!
    def show
      private_post = Thredded::PrivatePost.find!(params[:id])
      authorize private_post, :read?
      redirect_to post_url(private_post, user: thredded_current_user), status: :found
    end
  end
end
