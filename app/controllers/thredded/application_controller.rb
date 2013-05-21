module Thredded
  class ApplicationController < ActionController::Base

    private

    def messageboard
      @messageboard ||= Messageboard
        .where(name: params[:messageboard_id])
        .order('id ASC')
        .first
    end

    def ensure_messageboard_exists
      if messageboard.blank?
        redirect_to thredded.root_path,
          flash: { error: 'This messageboard does not exist.' }
      end
    end
  end
end
