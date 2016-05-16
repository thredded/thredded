# frozen_string_literal: true
module Thredded
  class PrivatePostPermalinksController < ApplicationController
    before_action :thredded_require_login!
    def show
      private_post = PrivatePost.find(params[:id])
      authorize private_post, :read?
      redirect_to post_url(private_post), status: :found
    end
  end
end
