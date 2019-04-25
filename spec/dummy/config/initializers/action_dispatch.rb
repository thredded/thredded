# frozen_string_literal: true

# Work around https://github.com/rails/rails/issues/35137
if Rails::VERSION::STRING == '6.0.0.rc1'
  module ActionDispatch
    class ContentSecurityPolicy
      private

      def nonce_directive?(directive)
        %w[script-src].include?(directive)
      end
    end
  end
end
