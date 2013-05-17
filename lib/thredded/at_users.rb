require 'thredded/at_notification_extractor'

module Thredded
  class AtUsers
    def self.render(content, messageboard)
      at_names = AtNotificationExtractor.new(content).extract
      members = messageboard.members_from_list(at_names)

      members.each do |member|
        content.gsub!(/@#{member.name}/i,
          %Q{<a href="/users/#{member.name}">@#{member.name}</a>})
      end

      content
    end
  end
end
