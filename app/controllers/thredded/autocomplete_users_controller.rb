# frozen_string_literal: true

module Thredded
  class AutocompleteUsersController < Thredded::ApplicationController
    MAX_RESULTS = 20

    def index
      users = users_by_prefix

      render json: UserSerializer.new(users).serializable_hash.to_json, status: 200
    end

    private

    def users_by_prefix
      query = params[:q].to_s.strip
      if query.length >= Thredded.autocomplete_min_length
        case_insensitive = DbTextSearch::CaseInsensitive.new(users_scope, Thredded.user_name_column)
        case_insensitive.prefix(query)
          .where.not(id: thredded_current_user.id)
          .order(case_insensitive.column_for_order(:asc))
          .limit(MAX_RESULTS)
      else
        []
      end
    end

    def users_scope
      thredded_current_user.thredded_can_message_users
    end
  end
end
