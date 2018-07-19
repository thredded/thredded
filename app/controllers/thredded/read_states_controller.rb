# frozen_string_literal: true

module Thredded
  class ReadStatesController < Thredded::ApplicationController
    before_action :thredded_require_login!

    def update
      Thredded::MarkAllRead.run(thredded_current_user) if thredded_signed_in?

      redirect_to request.referer
    end
  end
end
