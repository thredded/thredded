require 'spec_helper'

module Thredded
  describe PostMailer, 'at_notification' do
    it 'sets the correct headers' do
      expect(email.from).to eq(['no-reply@example.com'])
      expect(email.to).to eq(['no-reply@example.com'])
      expect(email.bcc).to eq(%w(john@email.com sam@email.com))
      expect(email.reply_to).to eq(['abcd@incoming.example.com'])
      expect(email.subject).to eq('[Thredded] A title')
    end

    it 'renders the body' do
      expect(email.body.encoded).to include('joel mentioned you in')
      expect(email.body.encoded).to include('hey @john @sam blarghy blurp')
    end

    def email
      @email ||= begin
        joel = build_stubbed(:user, name: 'joel')
        build_stubbed(:user, email: 'john@email.com')
        build_stubbed(:user, email: 'sam@email.com')
        topic = build_stubbed(:topic,
          hash_id: 'abcd',
          title: 'A title',
          user: joel,
        )
        post = build_stubbed(:post,
          postable: topic,
          user: joel,
          content: 'hey @john @sam blarghy blurp',
        )
        allow(Post).to receive_messages(find: post)
        emails = %w(john@email.com sam@email.com)

        PostMailer.at_notification(post.id, emails)
      end
    end
  end
end
