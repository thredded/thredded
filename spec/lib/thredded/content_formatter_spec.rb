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
    around do |ex|
      begin
        user_path_was = Thredded.class_variable_get(:@@user_path)
        ex.call
      ensure
        Thredded.user_path = user_path_was
      end
    end
    it 'links @names of members' do
      Thredded.user_path = ->(user) { "/whois/#{user.name}" }
      post_content = '@"sam 1" and @joe. But not @unknown, email@jane.com, email@joe.com, <code>@joe</code>.'
      sam = build_stubbed(:user, name: 'sam 1')
      joe = build_stubbed(:user, name: 'joe')
      post = build_stubbed(:post, content: post_content)
      expected_html = '<p><a href="/whois/sam%201">@"sam 1"</a> and <a href="/whois/joe">@joe</a>. But not @unknown, '\
'<a href="mailto:email@jane.com">email@jane.com</a>, <a href="mailto:email@joe.com">email@joe.com</a>,'\
' <code>@joe</code>.</p>'

      expect(post).to receive(:readers_from_user_names)
        .with(['sam 1', 'joe', 'unknown'])
        .and_return([sam, joe])

      expect(format_post_content(post)).to eq expected_html
    end
  end
end
