module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard

    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = exception.message
      redirect_to root_path
    end

    private

    def current_ability
      @current_ability ||= Thredded::Ability.new(current_user)
    end

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
