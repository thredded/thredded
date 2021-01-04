# frozen_string_literal: true

module Thredded
  class ReadStatesController < Thredded::ApplicationController
    before_action :thredded_require_login!

    def update
      if thredded_signed_in?
        Thredded::MarkAllRead.run(thredded_current_user)
        head 204
      else
        render json: {error: {message: 'Invalid email or password'} }, status: 401
      end
    end
  end
end
