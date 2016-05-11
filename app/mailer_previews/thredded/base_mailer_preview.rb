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
#{mention_users.map { |u| "@#{u}" } * ', '}, if we synthesize the driver, we can get to the HDD panel through the `1080p EXE` bus!
I'll program the **redundant** SMTP array, that should monitor the SMS microchip!
MARKDOWN
    end

    def mock_topic(attr = {})
      Topic.new(
        attr.reverse_merge(
          title:        'A test topic',
          slug:         'a-test-topic',
          created_at:   3.days.ago,
          id:           1 + rand(1334),
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
      )
    end

    def mock_private_topic(attr = {})
      PrivateTopic.new(
        attr.reverse_merge(
          title:       'A test private topic',
          slug:        'a-test-private-topic',
          created_at:  3.days.ago,
          id:          1 + rand(1334),
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
      )
    end

    def mock_messageboard(attr = {})
      Messageboard.new(
        attr.reverse_merge(
          name:         'A test messageboard',
          slug:         'a-test-messageboard',
          description:  'Test messageboard description',
          closed:       false,
          created_at:   1.month.ago,
          id:           1 + rand(1334),
          posts_count:  rand(1337),
          topics_count: rand(42),
          updated_at:   Time.zone.now,
        )
      )
    end

    def mock_user(attr = {})
      name = %w(Alice Bob).sample
      Thredded.user_class.new(
        attr.reverse_merge(
          Thredded.user_name_column => name,
          email:                    "#{name.downcase}@test.com",
        )
      )
    end
  end
end
