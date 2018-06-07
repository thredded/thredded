# frozen_string_literal: true

require 'factory_bot_rails'
require_relative '../../spec/support/features/fake_content'

# rubocop:disable HandleExceptions
begin
  if FactoryBot.factories.instance_variable_get(:@items).none?
    require_relative '../../spec/factories'
  end
rescue NameError
end
# rubocop:enable HandleExceptions
module Thredded
  class DatabaseSeeder # rubocop:disable Metrics/ClassLength
    module LogTime
      def self.included(base)
        base.extend ClassMethods
      end

      def log_time
        start = Time.now.to_f
        result = yield
        print_time_diff start
        result
      end

      def print_time_diff(from, to = Time.now.to_f)
        log " [#{format('%.2f', to - from)}s]\n"
      end

      module ClassMethods
        def log_method_time(method_name)
          prepend(Module.new do
            define_method method_name do |*args, **kwargs|
              log_time { super(*args, **kwargs) }
            end
          end)
          method_name
        end
      end
    end

    include LogTime

    SKIP_CALLBACKS = [
      [Thredded::Post, :commit, :after, :update_parent_last_user_and_time_from_last_post, on: %i[create destroy]],
      [Thredded::Post, :commit, :after, :update_parent_last_user_and_time_from_last_post_if_moderation_state_changed,
       on: :update],
      [Thredded::Post, :commit, :after, :auto_follow_and_notify, on: %i[create update]],
      [Thredded::PrivatePost, :commit, :after, :update_parent_last_user_and_timestamp, on: %i[create destroy]],
      [Thredded::PrivatePost, :commit, :after, :notify_users, on: [:create]],
    ].freeze
    DISABLE_COUNTER_CACHE = [Thredded::Post, Thredded::PrivatePost].freeze
    WRITEABLE_READONLY_ATTRIBUTES = [
      [Thredded::Topic, 'posts_count'],
      [Thredded::PrivateTopic, 'posts_count'],
    ].freeze

    # Applies global tweaks required to run seeder methods for the given block.
    def self.with_seeder_tweaks
      # Disable callbacks to avoid creating notifications and performing unnecessary updates
      DISABLE_COUNTER_CACHE.each do |klass|
        klass.send(:alias_method, :original_each_counter_cached_associations, :each_counter_cached_associations)
        klass.send(:define_method, :each_counter_cached_associations) {}
      end
      SKIP_CALLBACKS.each { |(klass, *args)| delete_callbacks(klass, *args) }
      WRITEABLE_READONLY_ATTRIBUTES.each { |(klass, attr)| klass.readonly_attributes.delete(attr) }
      logger_was = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      yield
    ensure
      # Re-enable callbacks and counter cache
      DISABLE_COUNTER_CACHE.each do |klass|
        klass.send(:remove_method, :each_counter_cached_associations)
        klass.send(:alias_method, :each_counter_cached_associations, :original_each_counter_cached_associations)
        klass.send(:remove_method, :original_each_counter_cached_associations)
      end
      SKIP_CALLBACKS.each do |(klass, *args)|
        args = args.dup
        klass.send(:set_options_for_callbacks!, args)
        klass.set_callback(*args)
      end
      WRITEABLE_READONLY_ATTRIBUTES.each { |(klass, attr)| klass.readonly_attributes << attr }
      ActiveRecord::Base.logger = logger_was
    end

    def self.delete_callbacks(klass, name, *filter_list, &block)
      type, filters, _options = klass.normalize_callback_params(filter_list, block)
      klass.__update_callbacks(name) do |target, chain|
        filters.each do |filter|
          chain.delete(chain.find { |c| c.matches?(type, filter) })
        end
        target.send :set_callbacks, name, chain
      end
    end

    def self.run(**kwargs)
      new.run(**kwargs)
    end

    def run(users: 200, topics: 70, posts: (1..60))
      log "Seeding the database...\n"
      self.class.with_seeder_tweaks do
        t_txn_0 = nil
        Messageboard.transaction do
          initialize_fake_post_contents(topics: topics, posts: posts)
          users(count: users)
          first_messageboard
          topics(count: topics)
          private_topics(count: topics)
          posts(count: posts)
          private_posts(count: posts)
          create_additional_messageboards
          follow_some_topics
          read_some_topics(count: (topics / 4..topics / 3))
          update_messageboards_data
          t_txn_0 = Time.now.to_f
          log 'Committing transaction and running after_commit callbacks'
        end
        print_time_diff t_txn_0
      end
    end

    def log(message)
      STDERR.write "- #{message}"
      STDERR.flush
    end

    log_method_time def initialize_fake_post_contents(topics:, posts:)
      log 'Initializing fake post contents...'
      @fake_post_contents = Array.new([topics * (posts.min + posts.max) / 2, 1000].min) { FakeContent.post_content }
    end

    def fake_post_contents
      @fake_post_contents ? @fake_post_contents.sample : FakeContent.post_content
    end

    def first_user
      @first_user ||= FirstUser.new(self).find_or_create
    end

    def users(count: 1)
      @users ||= Users.new(self).find_or_create(count: count)
    end

    def user_details
      @user_details ||= users.each_with_object({}) do |user, hash|
        hash[user] = user.thredded_user_detail
      end
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
      log "Creating #{additional_messageboards.length} additional messageboards...\n"
      additional_messageboards.each do |(name, description, group_id)|
        messageboard = Messageboard.create!(name: name, description: description, messageboard_group_id: group_id)
        topics = Topics.new(self).create(count: 1 + rand(3), messageboard: messageboard)
        Posts.new(self).create(count: (1..2), topics: topics)
      end
    end

    log_method_time def update_messageboards_data(**) # `**` for Ruby < 2.5, see https://bugs.ruby-lang.org/issues/10856
      log 'Updating messageboards data...'
      Messageboard.all.each do |messageboard|
        messageboard.update_last_topic!
        Thredded::Messageboard.reset_counters(messageboard.id, :posts)
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

    log_method_time def follow_some_topics(count: (5..10), count_users: (1..5))
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

    log_method_time def read_some_topics(count: (5..10), count_users: (1..5))
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
      read_state = Thredded::UserTopicReadState.find_or_initialize_by(user_id: user_id, postable_id: topic.id)
      if rand(2).zero?
        read_state.update!(read_at: topic.updated_at)
      else
        read_state.update!(read_at: topic.posts.order_newest_first.first(2).last.created_at)
      end
    end

    class BaseSeedData
      include LogTime

      # @return [Thredded::DatabaseSeeder]
      attr_reader :seeder

      def initialize(seed_database = DatabaseSeeder.new)
        @seeder = seed_database
      end

      # Utility method
      def self.create(*args)
        new.create(*args)
      end

      delegate :log, to: :seeder

      def find_or_create(*args)
        return @stored if @stored
        @stored = (find || create(*args))
      end

      def range_of_dates_in_order(up_to: Time.zone.now, count: 1)
        written = up_to
        Array.new(count - 1) { written -= random_duration(10.minutes..6.hours) }.reverse + [up_to]
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

      def random_duration(range)
        (range.min.to_i + rand(range.max.to_i)).seconds
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
        FactoryBot.create(:user, :approved, :admin, name: 'Joe', email: 'joe@example.com')
      end
    end

    # Thredded::DatabaseSeeder::Users.create(count:200)
    class Users < CollectionSeedData
      MODEL_CLASS = User

      log_method_time def create(count: 1)
        log "Creating #{count} users..."
        approved_users_count = (count * 0.97).round
        [seeder.first_user] +
        FactoryBot.create_list(:user, approved_users_count, :approved, :with_user_details) +
        FactoryBot.create_list(:user, count - approved_users_count, :with_user_details)
      end
    end

    class FirstMessageboard < FirstSeedData
      MODEL_CLASS = Messageboard

      log_method_time def create(**) # `**` for Ruby < 2.5, see https://bugs.ruby-lang.org/issues/10856
        log 'Creating a messageboard...'
        @first_messageboard = FactoryBot.create(
          :messageboard,
          name: 'Main Board',
          slug: 'main-board',
          description: 'A board is not a board without some posts'
        )
      end
    end

    class Topics < CollectionSeedData
      MODEL_CLASS = Topic

      log_method_time def create(count: 1, messageboard: seeder.first_messageboard)
        log "Creating #{count} topics in #{messageboard.name}..."
        Array.new(count) do
          FactoryBot.build(
            :topic,
            messageboard: messageboard,
            user: seeder.users.sample,
            last_user: seeder.users.sample
          ).tap do |topic|
            topic.user_detail = seeder.user_details[topic.user]
            topic.send :set_slug
            topic.send :set_default_moderation_state
            topic.save(validate: false)
          end
        end
      end
    end

    class PrivateTopics < CollectionSeedData
      MODEL_CLASS = PrivateTopic

      log_method_time def create(count: 1)
        log "Creating #{count} private topics..."
        Array.new(count) do
          FactoryBot.build(
            :private_topic,
            user: seeder.users[1..-1].sample,
            last_user: seeder.users.sample,
            users: [seeder.first_user, *seeder.users.sample(1 + rand(3))]
          ).tap do |topic|
            topic.send :set_slug
            topic.save(validate: false)
          end
        end
      end
    end

    class Posts < CollectionSeedData
      MODEL_CLASS = Post

      log_method_time def create(count: (1..1), topics: seeder.topics) # rubocop:disable Metrics/MethodLength
        log "Creating #{count} additional posts in each topic..."
        topics.flat_map do |topic|
          last_post_at = random_duration(0..256.hours).ago
          posts_count = (count.min + rand(count.max + 1))
          posts = range_of_dates_in_order(up_to: last_post_at, count: posts_count).map.with_index do |written_at, i|
            author = i.zero? ? topic.user : seeder.users.sample
            Post.new(
              content: seeder.fake_post_contents,
              messageboard_id: topic.messageboard_id,
              postable: topic,
              user: author,
              user_detail: seeder.user_details[author],
              created_at: written_at,
              updated_at: written_at,
            ).tap do |post|
              post.send :set_default_moderation_state
              post.save(validate: false)
            end
          end
          topic.update_columns(
            posts_count: posts_count,
            last_user_id: posts.last.user.id,
            updated_at: last_post_at,
            last_post_at: last_post_at
          )
          posts
        end
      end
    end

    class PrivatePosts < CollectionSeedData
      MODEL_CLASS = PrivatePost

      log_method_time def create(count: (1..1))
        log "Creating #{count} additional posts in each private topic..."
        seeder.private_topics.flat_map do |topic|
          last_post_at = random_duration(0..256.hours).ago
          posts_count = (count.min + rand(count.max + 1))
          posts = range_of_dates_in_order(up_to: last_post_at, count: posts_count).map.with_index do |written_at, i|
            author = i.zero? ? topic.user : topic.users.sample
            PrivatePost.new(
              postable: topic,
              user: author,
              created_at: written_at,
              updated_at: written_at,
              content: seeder.fake_post_contents,
            ).tap do |post|
              post.save(validate: false)
            end
          end
          topic.update_columns(
            posts_count: posts_count,
            last_user_id: posts.last.user.id,
            updated_at: last_post_at,
            last_post_at: last_post_at
          )
          posts
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
