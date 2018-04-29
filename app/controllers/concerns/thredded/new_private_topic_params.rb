# frozen_string_literal: true

module Thredded
  # @api private
  module NewPrivateTopicParams
    protected

    def new_private_topic_params
      params
        .fetch(:private_topic, {})
        .permit(:title, :content, :user_names, user_ids: [])
        .merge(
          user: thredded_current_user,
          ip: request.remote_ip
        ).tap { |p| adapt_user_ids! p }
    end

    private

    # Allow a string of IDs joined with commas.
    def adapt_user_ids!(p)
      p[:user_ids] = p[:user_ids].split(',') if p[:user_ids].is_a?(String)
    end
  end
end
