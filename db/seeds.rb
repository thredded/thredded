# frozen_string_literal: true
require 'factory_girl_rails'

# rubocop:disable HandleExceptions
begin
  if FactoryGirl.factories.instance_variable_get(:@items).none?
    require_relative '../spec/factories'
  end
rescue NameError
end
# rubocop:enable HandleExceptions

module Thredded
  class SeedDatabase
    attr_reader :user, :users, :messageboard, :topics, :private_topics, :posts

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
        s.create_first_user
        s.create_users(count: users)
        s.create_messageboard
        s.create_topics(count: topics)
        s.create_posts(count: posts)
        s.create_private_posts(count: posts)
        s.create_additional_messageboards
        s.log 'Running after_commit callbacks'
      end
    ensure
      # Re-enable callbacks
      SKIP_CALLBACKS.each { |(klass, *args)| klass.set_callback(*args) }
    end

    def log(message)
      STDERR.puts "- #{message}"
    end

    def create_first_user
      @user ||= ::User.first || FactoryGirl.create(:user, :approved, :admin, name: 'Joe', email: 'joe@example.com')
    end

    def create_users(count:)
      log "Creating #{count} users..."
      @users = [user] + FactoryGirl.create_list(:user, count, *(%i(approved) if rand > 0.1))
    end

    def create_messageboard
      log 'Creating a messageboard...'
      @messageboard = FactoryGirl.create(
        :messageboard,
        name:        'Main Board',
        slug:        'main-board',
        description: 'A board is not a board without some posts'
      )
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

    def create_topics(count: 26, messageboard: self.messageboard)
      log "Creating #{count} topics in #{messageboard.name}..."
      @topics = FactoryGirl.create_list(
        :topic, count,
        messageboard: messageboard,
        user:         users.sample,
        last_user:    users.sample
      )

      @private_topics = FactoryGirl.create_list(
        :private_topic, count,
        user:      users.sample,
        last_user: users.sample,
        users:     [user]
      )
    end

    def create_posts(count: (1..30))
      log "Creating #{count} additional posts in each topic..."
      @posts = topics.flat_map do |topic|
        (count.min + rand(count.max + 1)).times do
          FactoryGirl.create(:post, postable: topic, messageboard: messageboard, user: users.sample)
        end
      end
    end

    def create_private_posts(count: (1..30))
      log "Creating #{count} additional posts in each private topic..."
      @private_posts = private_topics.flat_map do |topic|
        (count.min + rand(count.max + 1)).times do
          FactoryGirl.create(:private_post, postable: topic, user: users.sample)
        end
      end
    end
  end
end

Thredded::SeedDatabase.run
