# frozen_string_literal: true

module Thredded
  # @api private
  module NewPrivatePostParams
    protected

    def new_private_post_params
      params.fetch(:post, {})
        .permit(:content)
    end
  end
end
