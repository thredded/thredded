require 'spec_helper'

module Thredded
  describe Post, 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:messageboard_id) }
  end

  describe Post, 'associations' do
    it { should have_many(:post_notifications).dependent(:destroy) }
    it { should belong_to(:user_detail) }
  end

  context 'when a parent user is nil' do
    describe Post, '#user_email and #user_anonymous?' do
      it 'is nil' do
        post = build_stubbed(:post, user: nil)

        expect(post.user_email).to eq nil
        expect(post.user_anonymous?).to be_truthy
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
  end

  describe Post, '#filtered_content' do
    let(:view_context) { ViewContextStub }
    before(:each) { @post  = build(:post) }
    after { Thredded.user_path = nil }

    module ViewContextStub
      def main_app; end
    end

    it 'renders bbcode url tags' do
      @post.content = 'go to [url]http://google.com[/url]'
      expected_html = '<p>go to <a href="http://google.com">google.com</a></p>'
      expect(@post.filtered_content(view_context)).to eq(expected_html)
    end

    it 'renders more bbcode' do
      @post.content = 'this is [b]bold[/b]'
      expect(@post.filtered_content(view_context))
          .to eq('<p>this is <strong>bold</strong></p>')
    end

    it 'handles bbcode quotes' do
      @post.content = <<-BBCODE.strip_heredoc
        [quote]hi[/quote]
        [quote=john]hey[/quote]
      BBCODE
      expected_html = <<-HTML.strip_heredoc
        <blockquote>
        hi
        </blockquote>

        john says
        <blockquote>
        hey
        </blockquote>
      HTML
      resulting_parsed_html = parsed_html(@post.filtered_content(view_context))
      expected_parsed_html  = parsed_html(expected_html)

      expect(resulting_parsed_html).to eq(expected_parsed_html)
    end

    it 'handles nested quotes' do
      @post.content = <<-BBCODE.strip_heredoc
      [quote=joel]
      [quote=john]hello[/quote]
      hi
      [/quote]
      BBCODE
      expected_html = <<-HTML.strip_heredoc
          joel says
          <blockquote>
            john says
            <blockquote>
            hello
            </blockquote>
          <p>hi</p>
          <p></p>
          </blockquote><br>
      HTML

      resulting_parsed_html = parsed_html(@post.filtered_content(view_context))
      expected_parsed_html  = parsed_html(expected_html)

      expect(resulting_parsed_html).to eq(expected_parsed_html)
    end

    it 'converts markdown to html' do
      @post.content = <<-MARKDOWN.strip_heredoc
        # Header

        http://www.google.com
      MARKDOWN
      expected_html = <<-HTML.strip_heredoc
        <h1>Header</h1>
        <p><a href="http://www.google.com">http://www.google.com</a></p>
      HTML

      resulting_parsed_html = parsed_html(@post.filtered_content(view_context))
      expected_parsed_html  = parsed_html(expected_html)

      expect(resulting_parsed_html).to eq(expected_parsed_html)
    end

    it 'performs some syntax highlighting in markdown' do
      @post.content = <<-MARKDOWN.strip_heredoc
        this is code

            def hello; puts 'world'; end

        right here
      MARKDOWN
      expected_html = <<-HTML.strip_heredoc.strip
        <p>this is code</p>

        <pre><code>def hello; puts 'world'; end
        </code></pre>

        <p>right here</p>
      HTML
      resulting_parsed_html = parsed_html(@post.filtered_content(view_context))
      expected_parsed_html  = parsed_html(expected_html)

      expect(resulting_parsed_html).to eq(expected_parsed_html)
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

    def parsed_html(html)
      Nokogiri::HTML::DocumentFragment.parse(html) { |config| config.noblanks }
        .to_html
        .gsub(/^\s*/, '')
        .gsub(/\s*$/, '')
        .gsub(/^$\n/, '')
    end
  end
end
