# frozen_string_literal: true
module Thredded
  # @api private
  module NewPrivateTopicParams
    protected

    def new_private_topic_params
      params
        .require(:private_topic)
        .permit(:title, :content, :user_ids, user_ids: [])
        .merge(
          user: thredded_current_user,
          ip: request.remote_ip
        ).tap { |p| adapt_user_ids! p }
    end

    private

    # select2 returns a string of IDs joined with commas.
    def adapt_user_ids!(p)
      p[:user_ids] = p[:user_ids].split(',') if p[:user_ids].is_a?(String)
    end
  end
end
