# frozen_string_literal: true

require 'spec_helper'

describe 'Thredded::CollectionToStringsWithCacheRenderer.render_collection_to_strings_with_cache', type: :helper do
  subject(:posts_with_contents) do
    # need to use helper (with type: :helper) in order to simulate a view_context / lookup_context
    helper.render_collection_to_strings_with_cache(
      partial: 'thredded/posts/content', collection: posts, as: :post, expires_in: 1.week,
      locals: { options: { users_provider: ::Thredded::UsersProviderWithCache.new } }
    )
  end

  let(:render_post_start) { '<div class="thredded--post--content">' }
  let(:collection_cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow_any_instance_of(Thredded::CollectionToStringsWithCacheRenderer) # rubocop:disable RSpec/AnyInstance
      .to receive(:collection_cache).and_return(collection_cache)
  end

  matcher :have_post_with_rendered_content do |expected_post|
    match(notify_expectation_failures: true) do |(actual_post, actual_content)|
      expect(actual_post).to eq(expected_post)
      expect(actual_content).to start_with(render_post_start)
      expect(actual_content).to include(expected_post.content)
    end
  end

  context 'with a single post' do
    let(:post) { create(:post, content: 'something new in sandwiches') }
    let(:posts) { [post] }

    it 'works' do
      expect(posts_with_contents.length).to eq(1)
      expect(posts_with_contents.first).to have_post_with_rendered_content(post)
    end
  end

  context 'with two different posts' do
    let(:post_1) { create(:post, content: 'one') }
    let(:post_2) { create(:post, content: 'two') }
    let(:posts) { [post_1, post_2] }

    shared_examples 'for two posts' do
      it 'has expected content for two posts' do
        expect(posts_with_contents.length).to eq(2)
        expect(posts_with_contents[0]).to have_post_with_rendered_content(post_1)
        expect(posts_with_contents[1]).to have_post_with_rendered_content(post_2)
      end
    end

    context 'with no threading' do
      before do
        allow(Thredded::CollectionToStringsWithCacheRenderer).to receive(:render_threads).and_return(1)
      end

      include_examples 'for two posts'
    end

    context 'with threading as default', threaded_render: true do
      include_examples 'for two posts'
    end

    context 'with two different posts in cache' do
      let(:cached_post_start) { '<div class="cached">' }

      before do
        expect(collection_cache).to receive(:read_multi) do |*keys|
          keys.zip([post_1, post_2]).to_h do |key, post|
            [key, "#{cached_post_start}#{post.content}</div>"]
          end
        end
      end

      # overridden matcher for cached post
      matcher :have_post_with_rendered_content do |expected_post|
        match(notify_expectation_failures: true) do |(actual_post, actual_content)|
          expect(actual_post).to eq(expected_post)
          expect(actual_content).to start_with(cached_post_start)
          expect(actual_content).to include(expected_post.content)
        end
      end

      context 'with no threading' do
        before do
          allow(Thredded::CollectionToStringsWithCacheRenderer).to receive(:render_threads).and_return(1)
        end

        include_examples 'for two posts'
      end

      context 'with threading as default' do
        include_examples 'for two posts'
      end
    end
  end

  context 'with two posts, one duplicated' do
    let(:post_1) { create(:post, content: 'one') }
    let(:post_2) { create(:post, content: 'two') }
    let(:posts) { [post_1, post_1, post_2] }

    shared_examples 'two posts, one duplicated' do
      it 'has expected content for two posts, one duplicated' do
        expect(posts_with_contents.length).to eq(3)
        expect(posts_with_contents[0]).to have_post_with_rendered_content(post_1)
        expect(posts_with_contents[1]).to have_post_with_rendered_content(post_1)
        expect(posts_with_contents[2]).to have_post_with_rendered_content(post_2)
      end
    end

    context 'with no threading' do
      before do
        allow(Thredded::CollectionToStringsWithCacheRenderer).to receive(:render_threads).and_return(1)
      end

      include_examples 'two posts, one duplicated'
    end

    context 'with threading as default', threaded_render: true do
      include_examples 'two posts, one duplicated'
    end
  end
end
