# frozen_string_literal: true

module Thredded
  class RelaunchUser < ActiveRecord::Base

    validates :email, presence: true, uniqueness: true
    validates :username, presence: true, uniqueness: true

    after_commit :notify_relaunch_user, on: :create

    def self.find!(slug_or_id)
      find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::RelaunchUserNotFound
    end

    private

    def notify_relaunch_user
      Thredded::NotifyRelaunchUserJob.perform_later(id)
    end

  end
end
