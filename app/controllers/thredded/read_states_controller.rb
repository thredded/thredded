# frozen_string_literal: true
module Thredded
  class ReadStatesController < Thredded::ApplicationController
    before_action :thredded_require_login!

    def update
      MarkAllRead.run(thredded_current_user) if signed_in?

      redirect_to request.referer
    end
  end
end
