# frozen_string_literal: true
require 'spec_helper'

module Thredded
  context 'when a parent user is nil' do
    describe Post, '#user_email' do
      it 'is nil' do
        post = build_stubbed(:post, user: nil)

        expect(post.user_email).to eq nil
      end
    end
  end

  describe Post, '#create' do
    it 'notifies anyone @ mentioned in the post' do
      mail = double('Thredded::PostMailer.at_notification(...)', deliver_later: true)

      expect(Thredded::PostMailer).to receive(:at_notification).with(1, ['joel@example.com']).and_return(mail)

      messageboard = create(:messageboard)
      joel = create(:user, name: 'joel', email: 'joel@example.com')
      create(
        :user_messageboard_preference,
        user: joel,
        messageboard: messageboard,
        notify_on_mention: true
      )

      expect(mail).to receive(:deliver_later)

      create(:post, id: 1, content: 'hi @joel', messageboard: messageboard)
    end

    it 'updates the parent topic with the latest post author' do
      joel  = create(:user)
      topic = create(:topic)
      create(:post, user: joel, postable: topic)

      expect(topic.reload.last_user).to eq joel
    end

    it "increments the topic's and user's post counts" do
      joel = create(:user)
      joel_details = create(:user_detail, user: joel)
      topic = create(:topic)
      create_list(:post, 3, postable: topic, user: joel)

      expect(topic.reload.posts_count).to eq 3
      expect(joel_details.reload.posts_count).to eq 3
    end

    it 'updates the topic updated_at field to that of the new post' do
      joel  = create(:user)
      topic = create(:topic)
      future_time = 3.hours.from_now
      create(:post, postable: topic, user: joel, content: 'posting here')
      travel_to future_time do
        create(:post, postable: topic, user: joel, content: 'posting more')
      end

      expect(topic.updated_at.to_s).to eq future_time.to_s
    end

    it 'sets the post user email on creation' do
      shaun = create(:user)
      topic = create(:topic, last_user: shaun)
      post = create(:post, user: shaun, postable: topic)

      expect(post.user_email).to eq post.user.email
    end

    it 'creates a follow for creator' do
      shaun = create(:user)
      topic = create(:topic)

      expect { create(:post, user: shaun, postable: topic) }
        .to change { shaun.thredded_topic_follows(true).count }.from(0).to(1)
      expect(Thredded::UserTopicFollow.last.reason).to eq(Thredded::UserTopicFollow::REASON_POSTED)
    end

    it "doesn't create a follow if creator already has a follow" do
      shaun = create(:user)
      topic = create(:topic)
      create(:user_topic_follow, user_id: shaun.id, topic_id: topic.id)

      expect { create(:post, user: shaun, postable: topic) }
        .to_not change { shaun.thredded_topic_follows(true).count }.from(1)
    end
  end

  describe Post, '#destroy' do
    it 'updates the topic updated_at field to that of the last post' do
      user_1 = create(:user)
      user_2 = create(:user)
      topic = create(:topic, with_posts: 1)
      post_1 = create(:post, postable: topic, user: user_1, content: 'posting more')
      future_time = 3.hours.from_now
      travel_to future_time do
        post_2 = create(:post, postable: topic, user: user_2, content: 'posting more')
        expect(topic.updated_at.to_s).to eq post_2.created_at.to_s
        expect(topic.last_user).to eq user_2
        post_2.destroy
      end
      expect(topic.updated_at.to_s).to eq post_1.created_at.to_s
      expect(topic.last_user).to eq user_1
    end
  end

  describe Post, '#filtered_content' do
    let(:view_context) { ViewContextStub }
    before(:each) { @post = build(:post) }
    after { Thredded.user_path = nil }

    module ViewContextStub
      def main_app; end
    end

    context 'various content from post_contents.yml' do
      yml = YAML.load(
        File.read("#{File.dirname(__FILE__)}/post_contents.yml")
      )

      yml.each do |title, contents|
        it "renders: '#{title}'" do
          @post.content = contents[0]
          expected_html = contents[1]

          resulting_parsed_html = parsed_html(@post.filtered_content(view_context))
          expected_parsed_html  = parsed_html(expected_html)

          expect(resulting_parsed_html).to eq(expected_parsed_html)
        end
      end

      def parsed_html(html)
        Nokogiri::HTML::DocumentFragment.parse(html, &:noblanks)
          .to_html
          .gsub(/^\s*/, '')
          .gsub(/\s*$/, '')
          .gsub(/^$\n/, '')
      end
    end

    it 'links @names of members' do
      Thredded.user_path = ->(user) { "/whois/#{user}" }
      post_content = 'for @sam but not @al or @kek. And @joe.'
      sam = build_stubbed(:user, name: 'sam')
      joe = build_stubbed(:user, name: 'joe')
      post = build_stubbed(:post, content: post_content)
      expected_html = '<p>for <a href="/whois/sam">@sam</a> but not @al or @kek. And <a href="/whois/joe">@joe</a>.</p>'

      expect(post).to receive(:readers_from_user_names)
        .with(%w(sam al kek joe))
        .and_return([sam, joe])

      expect(post.filtered_content(view_context)).to eq expected_html
    end
  end
end
