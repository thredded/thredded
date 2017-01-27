# frozen_string_literal: true
module Thredded
  class Stats
    include ActionView::Helpers::NumberHelper

    def messageboards_count
      number_to_human(messageboards.count, precision: 4)
    end

    def topics_count
      number_to_human(messageboards.map(&:topics_count).sum, precision: 4)
    end

    def posts_count
      number_to_human(messageboards.map(&:posts_count).sum, precision: 5)
    end

    def self.visible(*args)
      if self == ::Query
        # Visibility depends on permissions for each subclass,
        # raise an error if the scope is called from Query (eg. Query.visible)
        raise Exception.new("Cannot call .visible scope from the base Query class, but from subclasses only.")
      end

      user = args.shift || User.current
      base = Project.allowed_to_condition(user, view_permission, *args)
      scope = joins("LEFT OUTER JOIN #{Project.table_name} ON #{table_name}.project_id = #{Project.table_name}.id").
      where("#{table_name}.project_id IS NULL OR (#{base})")

      if user.admin?
        scope.where("#{table_name}.visibility <> ? OR #{table_name}.user_id = ?", VISIBILITY_PRIVATE, user.id)
      elsif user.memberships.any?
        scope.where("#{table_name}.visibility = ?" +
                    " OR (#{table_name}.visibility = ? AND #{table_name}.id IN (" +
                    "SELECT DISTINCT q.id FROM #{table_name} q" +
                      " INNER JOIN #{table_name_prefix}queries_roles#{table_name_suffix} qr on qr.query_id = q.id" +
                      " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = qr.role_id" +
                      " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
                      " WHERE q.project_id IS NULL OR q.project_id = m.project_id))" +
                      " OR #{table_name}.user_id = ?",
                      VISIBILITY_PUBLIC, VISIBILITY_ROLES, user.id, user.id)
      elsif user.logged?
        scope.where("#{table_name}.visibility = ? OR #{table_name}.user_id = ?", VISIBILITY_PUBLIC, user.id)
      else
        scope.where("#{table_name}.visibility = ?", VISIBILITY_PUBLIC)
      end
    end

    private

    def messageboards
      @messageboards ||= Thredded::Messageboard.ordered
    end
  end
end
