# frozen_string_literal: true

module ThreddedSpecSupport
  def self.using_mysql?
    /mysql/i.match?(Thredded::DbTools.adapter)
  end
end
