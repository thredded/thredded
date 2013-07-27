module Thredded
  class PreferencesController < ApplicationController
    helper_method :preference

    def edit
    end

    def update
      preference.update_attributes(params[:messageboard_preference])

      redirect_to :back, flash: { notice: 'Your preferences are updated' }
    end

    def preference
      @preference ||= MessageboardPreference
        .where(messageboard_id: messageboard.id, user_id: current_user.id)
        .first_or_create!
    end
  end
end
