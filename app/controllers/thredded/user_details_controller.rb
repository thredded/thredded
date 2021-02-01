# frozen_string_literal: true

module Thredded
  class UserDetailsController < Thredded::ApplicationController # rubocop:disable Metrics/ClassLength

    before_action :thredded_require_login!

    after_action :verify_authorized

    def update
      @userDetails = Thredded::UserDetail.find!(params[:id])
      authorize @userDetails, :update?
      if @userDetails.update(user_details_params)
        @userDetails.profile_banner.attach(params[:profile_banner])
        render json: ThreddedUserShowDetailSerializer.new(@userDetails).serializable_hash.to_json, status: 200
      else
        render json: {errors: @userDetails.errors }, status: 422
      end
    end

    private

    def user_details_params
      params
        .require(:user_details)
        .permit(:profile_description, :occupation, :date_of_registration, :location, :camera, :cutting_program, :sound, :lighting, :website_url, :youtube_url, :facebook_url, :twitter_url, interests:[])
    end
  end
end
