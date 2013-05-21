module Thredded
  class MessageboardsController < ApplicationController
    before_filter :messageboard, only: :show

    def index
      @messageboards = Messageboard.where(closed: false)
    end
  end
end
