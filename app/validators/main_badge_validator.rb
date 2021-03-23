# frozen_string_literal: true

class MainBadgeValidator < ActiveModel::Validator
  def validate(record)
    return if !record.thredded_main_badge || record.thredded_badges.include?(record.thredded_main_badge)
    record.errors.add :badge, 'Du musst das Badge besitzen, um es als Hauptbadge markieren zu können.'
  end
end
