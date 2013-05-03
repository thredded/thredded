class AtNotifier
  def initialize(post)
    @post = post
  end

  def notifications_for_at_users
    members = at_notifiable_members

    if members.present?
      user_emails = members.map(&:email)
      PostMailer.at_notification(post.id, user_emails).deliver
      mark_notified(members)
    end
  end

  def at_notifiable_members
    at_names = AtNotificationExtractor.new(post.content).extract
    members = post.messageboard.members_from_list(at_names).all

    members.delete post.user
    members = exclude_previously_notified(members)
    members = exclude_those_that_are_not_private(members)
    members = exclude_those_opting_out_of_at_notifications(members)

    members
  end

  private

  attr_reader :post

  def exclude_those_opting_out_of_at_notifications(members)
    members.reject do |member|
      !member.at_notifications_for?(post.messageboard)
    end
  end

  def exclude_those_that_are_not_private(members)
    members.reject do |member|
      post.topic.private? && post.topic.users.exclude?(member)
    end
  end

  def exclude_previously_notified(members)
    emails_notified = post.post_notifications.map(&:email)

    members.reject do |member|
      emails_notified.include? member.email
    end
  end

  def mark_notified(members)
    members.each do |member|
      post.post_notifications.create(email: member.email)
    end
  end
end
