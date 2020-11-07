# frozen_string_literal: true

module Thredded
  class PostPermalinksController < Thredded::ApplicationController
    def show
    begin
      post = Thredded::Post.find!(params[:id])
      authorize post, :read?
    rescue ActiveRecord::RecordNotFound
      render json: {errors: post.errors }, status: 404
      return
    rescue Exception
      raise
    end
    render json: PostPermalinkSerializer.new(post).serialized_json, status: 200
    end
  end
end
