require 'spec_helper'

module Thredded
  describe EmailProcessor, '.process' do
    it 'returns false if user or board is not found' do
      EmailProcessor.stub(extract_user_and_messageboard: [])
      email = build(:email)

      EmailProcessor.process(email).should == false
    end

    it 'returns false if user does not have right permissions' do
      email = build(:email, from: 'nope@email.com')
      user = create(:user, email: 'user@email.com')
      messageboard = create(:messageboard, name: 'eh', security: 'private')
      EmailProcessor.stub(extract_user_and_messageboard: [user, messageboard])

      EmailProcessor.process(email).should == false
    end

    context 'with existing user and messageboard' do
      before do
        joel = create(:user, email: 'joel@email.com')
        john = create(:user, email: 'john@email.com')
        mi = create(:messageboard, name: 'mi')
        mi.add_member(john)
        mi.add_member(joel)
        create(:topic,
          user: john,
          last_user: john,
          messageboard: mi,
          title: 'argument',
          hash_id: '1234')
      end

      context 'to existing topic' do
        it 'replies to a topic if specified' do
          email = build(:email, from: 'joel@email.com', to: '1234',
            subject: 'response', body: 'wrong!')
          EmailProcessor.process(email)

          latest_topic.title.should == 'argument'
          latest_topic.last_user.email.should == 'joel@email.com'
          latest_post.source.should == 'email'
          latest_post.content.should == 'wrong!'
        end
      end

      context 'to messageboard directly' do
        it 'creates a new topic if no topic specified' do
          email = build(:email,
            from: 'john@email.com',
            to: 'mi',
            subject: 'introduction',
            body: 'HI!'
          )
          EmailProcessor.process(email)

          latest_topic.title.should eq 'introduction'
          latest_post.source.should eq 'email'
          latest_post.content.should eq 'HI!'
        end


        it 'attaches a file' do
          email = build(:email, :with_attachments,
            from: 'joel@email.com',
            to: 'mi',
            subject: 'photo!',
            body: 'awesome!'
          )
          EmailProcessor.process(email)

          latest_post.attachments.should_not be_empty
        end
      end

      def latest_topic
        Topic.order('id DESC').first!
      end

      def latest_post
        Post.last!
      end
    end
  end
end
