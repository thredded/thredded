require "spec_helper"

module Thredded
  describe TopicMailer do
    describe 'message_notification' do
      it 'sends the right message' do
        joel = build_stubbed(:user, name: 'joel')
        john = build_stubbed(:user, name: 'john', email: 'john@example.com')
        sam = build_stubbed(:user, name: 'sam', email: 'sam@example.com')
        topic = build_stubbed(:private_topic,
          title: 'Private message',
          users: [john, sam],
          user: joel,
          posts: [build_stubbed(:post)]
        )
        Topic.stub(find: topic)
        emails = ['john@example.com', 'sam@example.com']

        mail = TopicMailer.message_notification(topic.id, emails)

        mail.subject.should eq '[Thredded]  Private message'
        mail.to.should eq ['no-reply@example.com']
        mail.from.should eq ['no-reply@example.com']
        mail.bcc.should eq ['john@example.com','sam@example.com']
        mail.body.encoded.should include('included you in the private topic')
      end
    end
  end
end
