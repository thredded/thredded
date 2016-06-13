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
          name = member.to_s
          content.gsub!(/(^|[\s>])(@#{Regexp.escape(name.include?(' ') ? %("#{name}") : name)})([^a-z\d]|$)/i,
                        %(\\1<a href="#{ERB::Util.html_escape member_path}">@#{ERB::Util.html_escape name}</a>\\3))
        end
      end

      content
    end
  end
end
