# frozen_string_literal: true

module Thredded
  class UserDetailsController < Thredded::ApplicationController # rubocop:disable Metrics/ClassLength

    before_action :thredded_require_login!

    after_action :verify_authorized

    def update
      now = Time.current
      user_details = Thredded::UserDetail.find_or_initialize_by(user_id: thredded_current_user.id)
      user_details.update!(last_seen_at: now)
      @user_details ||= Thredded::UserDetail.find!(params[:id])
      authorize @user_details, :update?
      if @user_details.update!(user_details_params)
        render json: ThreddedUserShowDetailSerializer.new(@user_details).serializable_hash.to_json, status: 200
      else
        render json: {errors: @user_details.errors }, status: 422
      end
    end

    private

    def user_details_params
      params
        .require(:user_details)
        .permit(:profile_description, :occupation, :date_of_registration, :location, :camera, :cutting_program, :sound, :lighting, :website_url, :youtube_url, :facebook_url, :twitter_url, :profile_banner, interests:[])
    end
  end
end
