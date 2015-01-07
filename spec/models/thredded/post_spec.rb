require 'spec_helper'
require 'chronic'
require 'timecop'

module Thredded
  describe Post, 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:messageboard_id) }
  end

  describe Post, 'associations' do
    it { should have_many(:post_notifications).dependent(:destroy) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should belong_to(:user_detail) }
  end

  context 'when a parent user is nil' do
    describe Post, '#user_email and #anonymous?' do
      it 'is nil' do
        post = build_stubbed(:post, user: nil)

        expect(post.user_email).to eq nil
        expect(post.user_anonymous?).to eq nil
      end
    end
  end

  describe Post, '#create' do
    after(:each) do
      Timecop.return
    end

    it 'notifies anyone @ mentioned in the post' do
      mail = double(deliver: true)
      allow(Thredded::PostMailer).to receive_messages(at_notification: mail)

      messageboard = create(:messageboard)
      joel = create(:user, name: 'joel', email: 'joel@example.com')
      messageboard.add_member(joel)
      create(
        :messageboard_preference,
        user: joel,
        messageboard: messageboard,
        notify_on_mention: true
      )

      expect(Thredded::PostMailer)
        .to receive(:at_notification).with(1, ['joel@example.com'])
      expect(mail).to receive(:deliver)

      create(:post, id: 1, content: 'hi @joel', messageboard: messageboard)
    end

    it 'updates the parent topic with the latest post author' do
      joel  = create(:user)
      topic = create(:topic)
      create(:post, user: joel, postable: topic)

      expect(topic.reload.last_user).to eq joel
    end

    it "increments the topic's and user's post counts" do
      joel  = create(:user)
      joel_details = create(:user_detail, user: joel)
      topic = create(:topic)
      create_list(:post, 3, postable: topic, user: joel)

      expect(topic.reload.posts_count).to eq 3
      expect(joel_details.reload.posts_count).to eq 3
    end

    it 'updates the topic updated_at field to that of the new post' do
      joel  = create(:user)
      topic = create(:topic)
      new_years_at_3pm = Chronic.parse('Jan 1st 2012 at 3:00pm').to_s

      Timecop.travel(Chronic.parse('Jan 1st 2012 at 12:00pm')) do
        create(:post, postable: topic, user: joel, content: 'posting here')
      end

      Timecop.travel(Chronic.parse('Jan 1st 2012 at 3:00pm')) do
        create(:post, postable: topic, user: joel, content: 'posting more')
      end

      expect(topic.updated_at.to_s).to eq new_years_at_3pm
    end

    it 'sets the post user email on creation' do
      shaun = create(:user)
      topic = create(:topic, last_user: shaun)
      post = create(:post, user: shaun, postable: topic)

      expect(post.user_email).to eq post.user.email
    end
  end

  describe Post, '#filter' do
    it 'defaults to the parent messageboard filter' do
      board_1 = create(:messageboard, filter: 'bbcode')
      board_2 = create(:messageboard, filter: 'markdown')

      post_1 = create(:post, messageboard: board_1)
      post_2 = create(:post, messageboard: board_2)

      expect(post_1.filter).to eq 'bbcode'
      expect(post_2.filter).to eq 'markdown'
    end
  end

  describe Post, '.filtered_content' do
    before(:each) do
      @post  = build(:post)
    end

    after do
      Thredded.user_path = nil
    end

    it 'renders implied urls' do
      @post.content = 'go to [url]http://google.com[/url]'
      @post.filter = 'bbcode'

      expect(@post.filtered_content).to eq '<p>go to <a href="http://google.com">http://google.com</a></p>'
    end

    it 'converts bbcode to html' do
      @post.content = 'this is [b]bold[/b]'
      @post.filter = 'bbcode'
      expect(@post.filtered_content).to eq '<p>this is <strong>bold</strong></p>'
    end

    it 'handles quotes' do
      @post.content = '[quote]hi[/quote] [quote=john]hey[/quote]'
      @post.filter = 'bbcode'
      expected_output = "<p></p><br>  <blockquote>\n<br>    hi<br>  </blockquote><br><br> <br>  john says<br>  <blockquote>\n<br>    hey<br>  </blockquote><br><br>"

      expect(parsed_html(@post.filtered_content))
        .to eq(parsed_html(expected_output))
    end

    it 'handles nested quotes' do
      @post.content = '[quote=joel][quote=john]hello[/quote] hi[/quote]'
      @post.filter = 'bbcode'
      expected_output = "<p></p><br>  joel says<br>  <blockquote>\n<br>    <br>  john says<br>  <blockquote>\n<br>    hello<br>  </blockquote>\n<br><br> hi<br>  </blockquote><br><br>"

      expect(parsed_html(@post.filtered_content))
        .to eq(parsed_html(expected_output))
    end

    it 'converts markdown to html' do
      @post.content = "# Header\nhttp://www.google.com"
      @post.filter = 'markdown'

      expect(@post.filtered_content).to eq "<h1>Header</h1>\n\n<p><a href=\"http://www.google.com\">http://www.google.com</a></p>"
    end

    it 'performs some syntax highlighting in markdown' do
      input = "this is code

      def hello; puts 'world'; end

  right here"

      expected_output = "<p>this is code</p>\n\n<pre><code>  def hello; puts 'world'; end\n</code></pre>\n\n<p>right here</p>"

      @post.content = input
      @post.filter = 'markdown'

      expect(@post.filtered_content).to eq expected_output
    end

    it 'links @names of members' do
      Thredded.user_path = ->(user) { "/whois/#{user}" }
      sam = build_stubbed(:user, name: 'sam')
      joe = build_stubbed(:user, name: 'joe')
      allow_any_instance_of(Messageboard).to receive_messages(members_from_list: [sam, joe])
      post = build_stubbed(:post, content: 'for @sam but not @al or @kek. And @joe.')
      expectation = '<p>for <a href="/whois/sam">@sam</a> but not @al or @kek. And <a href="/whois/joe">@joe</a>.</p>'

      expect(post.filtered_content).to eq expectation
    end

    def parsed_html(html)
      Nokogiri::HTML::DocumentFragment.parse(html).to_hash
    end
  end
end
