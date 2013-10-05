module Thredded
  class MessageboardsController < Thredded::ApplicationController
    before_filter :messageboard, only: :show

    def index
      @messageboards = Messageboard.where(closed: false)
    end
  end
end
