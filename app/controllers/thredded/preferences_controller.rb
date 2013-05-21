module Thredded
  class PreferencesController < ApplicationController
    def update
      @preference = Preference.find(params[:id])
      @preference.update_attributes(params[:preference])

      flash[:notice] = 'Messageboard preferences updated'
      redirect_to edit_user_registration_path('messageboard[name]' => @preference.messageboard.name)
    end
  end
end
