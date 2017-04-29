# frozen_string_literal: true
module Thredded
  # @api private
  module NewPostParams
    protected

    def new_post_params
      params.fetch(:post, {})
        .permit(:content)
        .merge(ip: request.remote_ip)
    end
  end
end
