# frozen_string_literal: true

module Thredded
  class PostPermalinksController < Thredded::ApplicationController
    def show
      post = Thredded::Post.find!(params[:id].to_s)
      authorize post, :read?
      render json: PostSerializer.new(post, include: %i[user messageboard]).serializable_hash.to_json, status: 200
    end
  end
end
