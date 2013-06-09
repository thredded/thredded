require 'spec_helper'

module Thredded
  describe PostMailer, 'at_notification' do
    before do
      create(:app_config, email_from: 'no-reply@thredded.com',
        incoming_email_host: 'reply.thredded.com',
        email_subject_prefix: '[Thredded]')
      joel = build_stubbed(:user, name: 'joel')
      john = build_stubbed(:user, email: 'john@email.com')
      sam = build_stubbed(:user, email: 'sam@email.com')
      topic = build_stubbed(:topic, hash_id: 'abcd', title: 'A title')

      post = build_stubbed(:post, topic: topic, user: joel,
        content: 'hey @john @sam blarghy blurp')
      Post.stubs(:find).returns(post)

      emails = ['john@email.com', 'sam@email.com']
      @mail = PostMailer.at_notification(post.id, emails)
    end

    it 'sets the correct headers' do
      @mail.from.should eq(['no-reply@thredded.com'])
      @mail.to.should eq(['no-reply@thredded.com'])
      @mail.bcc.should eq(['john@email.com','sam@email.com'])
      @mail.reply_to.should eq(['abcd@reply.thredded.com'])
      @mail.subject.should eq('[Thredded] A title')
    end

    it 'renders the body' do
      @mail.body.encoded.should include('joel mentioned you in')
      @mail.body.encoded.should include('hey @john @sam blarghy blurp')
    end
  end
end
