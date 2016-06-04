# frozen_string_literal: true
module Thredded
  class AtUsers
    # @param users_provider [#call(usernames)] given usernames, returns a list of users.
    def self.render(content, users_provider, view_context)
      at_names = AtNotificationExtractor.new(content).run

      if at_names.any?
        members = users_provider.call(at_names)

        members.each do |member|
          member_path = Thredded.user_path(view_context, member)
          content.gsub!(/(@#{member.to_s})\b/i,
                        %(<a href="#{ERB::Util.html_escape member_path}">\\1</a>))
        end
      end

      content
    end
  end
end
