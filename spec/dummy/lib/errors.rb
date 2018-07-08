# frozen_string_literal: true

module Errors
  class UserNotFound < StandardError
    def message
      'This user does not exist.'
    end
  end
end
