# frozen_string_literal: true

module Thredded
  class PrivatePostPermalinksController < Thredded::ApplicationController
    before_action :thredded_require_login!
    def show
      private_post = Thredded::PrivatePost.find!(params[:id].to_s)
      authorize private_post, :read?
      render json: PrivatePostSerializer.new(private_post, include: [:user]).serializable_hash.to_json, status: 200
    end
  end
end
