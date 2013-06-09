require "spec_helper"

module Thredded
  describe TopicMailer do
    describe "message_notification" do
      it 'sends the right message' do
        create(:app_config, email_from: 'no-reply@thredded.com',
          incoming_email_host: 'reply.thredded.com',
          email_subject_prefix: '[Thredded]')
        joel = build_stubbed(:user, name: 'joel')
        john = build_stubbed(:user, name: 'john', email: 'john@example.com')
        sam = build_stubbed(:user, name: 'sam', email: 'sam@example.com')
        topic = build_stubbed(:private_topic, title: 'Private message',
          users: [john, sam], user: joel, posts: [build_stubbed(:post)])
        emails = ['john@example.com', 'sam@example.com']
        Topic.stubs(:find).returns(topic)
        mail = TopicMailer.message_notification(topic.id, emails)

        mail.subject.should eq "[Thredded] Private message"
        mail.to.should eq ["no-reply@thredded.com"]
        mail.from.should eq ['no-reply@thredded.com']
        mail.bcc.should eq ['john@example.com','sam@example.com']
        mail.body.encoded.should include('included you in a private topic')
      end
    end
  end
end
