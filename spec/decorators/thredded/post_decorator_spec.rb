require 'spec_helper'
require 'chronic'
require 'timecop'

module Thredded
  describe PostDecorator, '#user_link' do
    after do
      Thredded.user_path = nil
    end

    it 'links to a valid user' do
      Thredded.user_path = ->(user) { "/i_am/#{user}" }
      user = create(:user, name: 'joel')
      post = create(:post, user: user)
      decorator = PostDecorator.new(post)

      expect(decorator.user_link).to eq "<a href='/i_am/joel'>joel</a>"
    end

    it 'links to nowhere for a null user' do
      user = nil
      post = create(:post, user: user)
      decorator = PostDecorator.new(post)

      expect(decorator.user_link).to eq '<a href="#">?</a>'
    end
  end

  describe PostDecorator, '#user_name' do
    it 'delegates to the user object' do
      user = build_stubbed(:user, name: 'joel')
      post = build_stubbed(:post, user: user)
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.user_name).to eq 'joel'
    end

    it 'returns Anonymous when there is no user' do
      post = build_stubbed(:post, user: nil)
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.user_name).to eq 'Anonymous'
    end
  end

  describe PostDecorator, '#created_at_timeago' do
    it 'prints something ambiguous for nils' do
      post = build_stubbed(:post)
      post.stub(created_at: nil)
      decorated_post = PostDecorator.new(post)
      ambiguous_message = <<-eohtml.strip_heredoc.html_safe
        <abbr>
          a little while ago
        </abbr>
      eohtml

      expect(decorated_post.created_at_timeago).to eq ambiguous_message
    end

    it 'prints a human readable/formatted date' do
      new_years = Chronic.parse('Jan 1 2013 at 3:00pm')

      Timecop.freeze(new_years) do
        post = build_stubbed(:post)
        decorated_post = PostDecorator.new(post)

        created_at_html = <<-eohtml.strip_heredoc.html_safe
          <abbr class="timeago" title="2013-01-01T15:00:00Z">
            2013-01-01 15:00:00 UTC
          </abbr>
        eohtml

        expect(decorated_post.created_at_timeago).to eq created_at_html
      end
    end
  end

  describe PostDecorator, '#gravatar_url' do
    it 'strips the protocol from the url' do
      post = build_stubbed(:post)
      post.stub(gravatar_url: 'http://example.com/me.jpg')
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.gravatar_url).to eq '//example.com/me.jpg'
    end
  end
end
