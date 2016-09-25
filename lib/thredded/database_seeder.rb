# frozen_string_literal: true
require 'factory_girl_rails'

# rubocop:disable HandleExceptions
begin
  if FactoryGirl.factories.instance_variable_get(:@items).none?
    require_relative '../../spec/factories'
  end
rescue NameError
end
# rubocop:enable HandleExceptions
module Thredded
  class DatabaseSeeder
    SKIP_CALLBACKS = [
      [Thredded::Post, :commit, :after, :auto_follow_and_notify],
      [Thredded::PrivatePost, :commit, :after, :notify_users],
    ].freeze

    def self.run(users: 200, topics: 55, posts: (1..60))
      STDERR.puts 'Seeding the database...'
      # Disable callbacks to avoid creating notifications and performing unnecessary updates
      SKIP_CALLBACKS.each { |(klass, *args)| klass.skip_callback(*args) }
      s = new
      Messageboard.transaction do
        s.seed(users: users, topics: topics, posts: posts)
        s.log 'Running after_commit callbacks'
      end
    ensure
      # Re-enable callbacks
      SKIP_CALLBACKS.each { |(klass, *args)| klass.set_callback(*args) }
    end

    def seed(users: 200, topics: 55, posts: (1..60))
      users(count: users)
      first_messageboard
      topics(count: topics)
      private_topics(count: topics)
      posts(count: posts)
      private_posts(count: posts)
      create_additional_messageboards
      follow_some_topics
      read_some_topics
    end

    def log(message)
      STDERR.puts "- #{message}"
    end

    def first_user
      @first_user ||= FirstUser.new(self).find_or_create
    end

    def users(count: 1)
      @users ||= Users.new(self).find_or_create(count: count)
    end

    def first_messageboard
      @first_messageboard ||= FirstMessageboard.new(self).find_or_create
    end

    def create_additional_messageboards
      meta_group_id = MessageboardGroup.create!(name: 'Meta').id
      additional_messageboards = [
        ['Off-Topic', "Talk about whatever here, it's all good."],
        ['Help, Bugs, and Suggestions',
         'Need help using the forum? Want to report a bug or make a suggestion? This is the place.', meta_group_id],
        ['Praise', 'Want to tell us how great we are? This is the place.', meta_group_id]
      ]
      log "Creating #{additional_messageboards.length} additional messageboards..."
      additional_messageboards.each do |(name, description, group_id)|
        messageboard = Messageboard.create!(name: name, description: description, messageboard_group_id: group_id)
        FactoryGirl.create_list(:topic, 1 + rand(3), messageboard: messageboard, with_posts: 1)
      end
    end

    def topics(count: 1)
      @topics ||= Topics.new(self).find_or_create(count: count)
    end

    def private_topics(count: 1)
      @private_topics ||= PrivateTopics.new(self).find_or_create(count: count)
    end

    def posts(count: (1..1))
      @posts ||= Posts.new(self).find_or_create(count: count)
    end

    def private_posts(count: (1..1))
      @private_posts ||= PrivatePosts.new(self).find_or_create(count: count)
    end

    def follow_some_topics(count: (5..10), count_users: (1..5))
      log 'Following some topics...'
      posts.each do |post|
        Thredded::UserTopicFollow.create_unless_exists(post.user_id, post.postable_id, :posted) if post.user_id
      end
      follow_some_topics_by_user(first_user, count: count)
      users.sample(count_users.min + rand(count_users.max - count_users.min + 2)).each do |user|
        follow_some_topics_by_user(user, count: count)
      end
    end

    def follow_some_topics_by_user(user, count: (1..10))
      topics.sample(count.min + rand(count.max - count.min + 2)).each do |topic|
        Thredded::UserTopicFollow.create_unless_exists(user.id, topic.id)
      end
    end

    def read_some_topics(count: (5..10), count_users: (1..5))
      log 'Reading some topics...'
      topics.each do |topic|
        read_topic(topic, topic.last_user_id) if topic.last_user_id
      end
      read_some_topics_by_user(first_user, count: count)
      @users.sample(count_users.min + rand(count_users.max - count_users.min + 2)).each do |user|
        read_some_topics_by_user(user, count: count)
      end
    end

    def read_some_topics_by_user(user, count: (1..10))
      topics.sample(count.min + rand(count.max - count.min + 2)).each do |topic|
        read_topic(topic, user.id)
      end
    end

    def read_topic(topic, user_id)
      Thredded::UserTopicReadState.find_or_initialize_by(user_id: user_id, postable_id: topic.id)
        .update!(read_at: topic.updated_at, page: 1)
    end

    class BaseSeedData
      attr_reader :seeder

      def initialize(seed_database)
        @seeder = seed_database
      end

      delegate :log, to: :seeder

      def find_or_create(*args)
        return @stored if @stored
        @stored = (find || create(*args))
      end

      protected

      def model_class
        self.class::MODEL_CLASS
      end

      # @abstract
      def create(*_args)
        fail 'Unimplemented'
      end

      # @abstract
      def find
        fail 'Unimplemented'
      end
    end

    class FirstSeedData < BaseSeedData
      def find
        model_class.first
      end
    end

    class CollectionSeedData < BaseSeedData
      def find
        return nil unless model_class.exists?
        model_class.all.to_a
      end
    end

    class FirstUser < FirstSeedData
      MODEL_CLASS = User

      def create
        log 'Creating first user...'
        FactoryGirl.create(:user, :approved, :admin, name: 'Joe', email: 'joe@example.com')
      end
    end

    class Users < CollectionSeedData
      MODEL_CLASS = User

      def create(count: 1)
        log "Creating #{count} users..."
        approved_users_count = (count * 0.97).round
        [seeder.first_user] +
          FactoryGirl.create_list(:user, approved_users_count, :approved) +
          FactoryGirl.create_list(:user, count - approved_users_count)
      end
    end

    class FirstMessageboard < FirstSeedData
      MODEL_CLASS = Messageboard

      def create
        log 'Creating a messageboard...'
        @first_messageboard = FactoryGirl.create(
          :messageboard,
          name: 'Main Board',
          slug: 'main-board',
          description: 'A board is not a board without some posts'
        )
      end
    end

    class Topics < CollectionSeedData
      MODEL_CLASS = Topic

      def create(count: 1, messageboard: seeder.first_messageboard)
        log "Creating #{count} topics in #{messageboard.name}..."
        FactoryGirl.create_list(
          :topic, count,
          messageboard: messageboard,
          user: seeder.users.sample,
          last_user: seeder.users.sample
        )
      end
    end

    class PrivateTopics < CollectionSeedData
      MODEL_CLASS = PrivateTopic

      def create(count: 1)
        FactoryGirl.create_list(
          :private_topic, count,
          user: seeder.users[1..-1].sample,
          last_user: seeder.users.sample,
          users: [seeder.first_user]
        )
      end
    end

    class Posts < CollectionSeedData
      MODEL_CLASS = Post

      def create(count: (1..1))
        log "Creating #{count} additional posts in each topic..."
        seeder.topics.flat_map do |topic|
          posted_at = (1 + rand(5)).days.ago
          max_posted_at = Time.zone.now
          posts = Array.new((count.min + rand(count.max + 1))) do
            posted_at += (1 + rand(60)).minutes
            posted_at = max_posted_at if posted_at > max_posted_at
            FactoryGirl.create(:post, postable: topic, messageboard: seeder.first_messageboard,
                                      user: seeder.users.sample, created_at: posted_at, updated_at: posted_at)
          end
          topic.update!(last_user_id: posts.last.user.id, updated_at: posted_at)
          posts
        end
      end
    end

    class PrivatePosts < CollectionSeedData
      MODEL_CLASS = PrivatePost

      def create(count: (1..1))
        log "Creating #{count} additional posts in each private topic..."
        seeder.private_topics.flat_map do |topic|
          (count.min + rand(count.max + 1)).times do
            FactoryGirl.create(:private_post, postable: topic, user: seeder.users.sample)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
