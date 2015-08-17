module Thredded
  class AtUsers
    def self.render(content, messageboard, view_context)
      at_names = AtNotificationExtractor.new(content).run

      if at_names.any?
        members = messageboard.members_from_list(at_names)

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
