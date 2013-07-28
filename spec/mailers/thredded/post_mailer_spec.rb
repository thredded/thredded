require 'spec_helper'

module Thredded
  describe PostMailer, 'at_notification' do
    it 'sets the correct headers' do
      email.from.should eq(['no-reply@example.com'])
      email.to.should eq(['no-reply@example.com'])
      email.bcc.should eq(['john@email.com','sam@email.com'])
      email.reply_to.should eq(['abcd@incoming.example.com'])
      email.subject.should eq('[Thredded]  A title')
    end

    it 'renders the body' do
      email.body.encoded.should include('joel mentioned you in')
      email.body.encoded.should include('hey @john @sam blarghy blurp')
    end

    def email
      @email ||= begin
        joel = build_stubbed(:user, name: 'joel')
        john = build_stubbed(:user, email: 'john@email.com')
        sam = build_stubbed(:user, email: 'sam@email.com')
        topic = build_stubbed(:topic,
          hash_id: 'abcd',
          title: 'A title',
          user: joel,
        )
        post = build_stubbed(:post,
          topic: topic,
          user: joel,
          content: 'hey @john @sam blarghy blurp',
        )
        Post.stub(find: post)
        emails = ['john@email.com', 'sam@email.com']

        PostMailer.at_notification(post.id, emails)
      end
    end
  end
end
