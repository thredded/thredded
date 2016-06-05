# frozen_string_literal: true
require 'spec_helper'

describe Thredded::ContentFormatter do
  module ViewContextStub
    def main_app; end
  end

  def format_post_content(post)
    Thredded::ContentFormatter.new(
      ViewContextStub,
      users_provider: -> (names) { post.readers_from_user_names(names) }
    ).format_content(post.content)
  end

  context 'various content from post_contents.yml' do
    YAML.load_file("#{File.dirname(__FILE__)}/post_contents.yml").each do |title, contents|
      it "renders: '#{title}'" do
        @post = build(:post)
        @post.content = contents[0]
        expected_html = contents[1]

        resulting_parsed_html = parsed_html(format_post_content(@post))
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

  context '@-mentions' do
    before { Thredded.user_path = ->(user) { "/whois/#{user}" } }
    after { Thredded.user_path = nil }
    it 'links @names of members' do
      post_content = 'for @sam but not @al or @kek. And @joe.'
      sam = build_stubbed(:user, name: 'sam')
      joe = build_stubbed(:user, name: 'joe')
      post = build_stubbed(:post, content: post_content)
      expected_html = '<p>for <a href="/whois/sam">@sam</a> but not @al or @kek. And <a href="/whois/joe">@joe</a>.</p>'

      expect(post).to receive(:readers_from_user_names)
        .with(%w(sam al kek joe))
        .and_return([sam, joe])

      expect(format_post_content(post)).to eq expected_html
    end
  end
end
