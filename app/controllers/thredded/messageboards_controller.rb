module Thredded
  class MessageboardsController < Thredded::ApplicationController
    def index
      @messageboards = Messageboard.where(closed: false).decorate
    end
  end
end
