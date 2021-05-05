# frozen_string_literal: true

module Thredded
  class UserDetailsController < Thredded::ApplicationController
    before_action :thredded_require_login!

    after_action :verify_authorized

    def update
      now = Time.current
      @user_details = Thredded::UserDetail.find_or_create_by(user_id: thredded_current_user.id)
      @user_details.update!(last_seen_at: now)
      @user_details ||= Thredded::UserDetail.find!(params[:id])
      authorize @user_details, :update?

      # delete current active storage profile_banner if empty
      params = user_details_params
      if params[:profile_banner] && params[:profile_banner] == ''
        @user_details.profile_banner.purge
        params.delete :profile_banner
      end

      if @user_details.update!(params)
        render json: ThreddedUserShowDetailSerializer.new(@user_details).serializable_hash.to_json, status: 200
      else
        render json: { errors: @user_details.errors }, status: 422
      end
    end

    private

    def user_details_params
      params
        .require(:user_details)
        .permit(
          :profile_description,
          :occupation,
          :date_of_registration,
          :location,
          :camera,
          :cutting_program,
          :sound,
          :lighting,
          :website_url,
          :youtube_url,
          :facebook_url,
          :twitter_url,
          :instagram_url,
          :profile_banner,
          interests: []
        )
    end
  end
end
