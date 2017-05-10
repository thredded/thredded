# frozen_string_literal: true

module Thredded
  # @api private
  module NewPrivatePostParams
    protected

    def new_private_post_params
      params.fetch(:post, {})
        .permit(:content, :quote_private_post_id)
        .merge(ip: request.remote_ip).tap do |p|
        quote_id = p.delete(:quote_private_post_id)
        if quote_id
          post = PrivatePost.find(quote_id)
          authorize_reading post
          p[:quote_post] = post
        end
      end
    end
  end
end
