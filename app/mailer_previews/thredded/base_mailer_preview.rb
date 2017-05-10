# frozen_string_literal: true

module Thredded
  # A base class for Thredded mailer previews.
  # @abstract
  class BaseMailerPreview
    def self.preview_classes
      RailsEmailPreview.find_preview_classes File.expand_path('..', File.dirname(__FILE__))
    end

    protected

    def mock_content(mention_users: [])
      <<-MARKDOWN
Hey #{mention_users.map { |u| "@#{u}" } * ', '}!
All of the basic [Markdown](https://kramdown.gettalong.org/quickref.html) formatting is supported (powered by [Kramdown](https://kramdown.gettalong.org)).

Additionally, Markdown is extended to support the following:

#{Thredded::FormattingDemoContent.parts.join("\n")}
      MARKDOWN
    end

    def mock_topic(attr = {})
      fail 'Do not assign ID here or a has_many association might get updated' if attr.key?(:id)
      Topic.new(
        attr.reverse_merge(
          title:        'A test topic',
          slug:         'a-test-topic',
          created_at:   3.days.ago,
          last_user:    mock_user,
          locked:       [false, true].sample,
          messageboard: mock_messageboard,
          posts_count:  1 + rand(42),
          sticky:       [false, true].sample,
          updated_at:   Time.zone.now,
          user:         mock_user,
        )
      )
    end

    def mock_post(attr = {})
      topic = attr[:postable] || mock_topic
      Post.new(
        attr.reverse_merge(
          content:      'A test post',
          created_at:   Time.zone.now,
          id:           1 + rand(1334),
          messageboard: topic.messageboard,
          postable:     topic,
          updated_at:   Time.zone.now,
          user:         topic.last_user,
        )
      ).tap { |m| mock_post_cache_key! m }
    end

    def mock_private_topic(attr = {})
      fail 'Do not assign ID here or a has_many association might get updated' if attr.key?(:id)
      PrivateTopic.new(
        attr.reverse_merge(
          title:       'A test private topic',
          slug:        'a-test-private-topic',
          created_at:  3.days.ago,
          last_user:   mock_user,
          posts_count: 1 + rand(42),
          updated_at:  Time.zone.now,
          user:        mock_user,
        )
      )
    end

    def mock_private_post(attr = {})
      private_topic = attr[:postable] || mock_private_topic
      PrivatePost.new(
        attr.reverse_merge(
          content:    'A test private post',
          created_at: Time.zone.now,
          id:         1 + rand(1334),
          postable:   private_topic,
          updated_at: Time.zone.now,
          user:       private_topic.last_user,
        )
      ).tap { |m| mock_post_cache_key! m }
    end

    def mock_messageboard(attr = {})
      fail 'Do not assign ID here or a has_many association might get updated' if attr.key?(:id)
      Messageboard.new(
        attr.reverse_merge(
          name:         'A test messageboard',
          slug:         'a-test-messageboard',
          description:  'Test messageboard description',
          created_at:   1.month.ago,
          posts_count:  rand(1337),
          topics_count: rand(42),
          updated_at:   Time.zone.now,
        )
      )
    end

    def mock_user(attr = {})
      name = %w[Alice Bob].sample
      Thredded.user_class.new(
        attr.reverse_merge(
          Thredded.user_name_column => name,
          email:                    "#{name.downcase}@test.com",
        )
      )
    end

    def mock_post_cache_key!(post)
      orig_key = post.cache_key
      post.define_singleton_method :cache_key do
        orig_key.sub(/new$/, "preview-#{Digest.hexencode(Digest::SHA2.new.digest(content))}")
      end
    end
  end
end
