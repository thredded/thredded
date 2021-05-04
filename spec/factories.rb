# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  sequence(:topic_hash) { |n| "hash#{n}" }

  factory :email, class: OpenStruct do
    to { 'email-token' }
    from { 'user@email.com' }
    subject { 'email subject' }

    body { 'Hello!' }
  end

  factory :category, class: Thredded::Category do
    sequence(:name) { |n| "category#{n}" }
    sequence(:description) { |n| "Category #{n}" }

    trait :beer do
      name { 'beer' }
      description { 'a delicious adult beverage' }
    end
  end

  factory :news, class: Thredded::News do
    sequence(:title) { |n| "title#{n}" }
  end

  factory :relaunch_user, class: Thredded::RelaunchUser do
    username { "john" }
    email { "john@email.com" }
  end

  factory :messageboard, class: Thredded::Messageboard do
    sequence(:name) { |n| "messageboard#{n}" }
    description { 'This is a description of the messageboard' }

    trait :for_movies do
      topic_types { ['Thredded::TopicMovie'] }
    end

    trait :with_badge do
      badge { create(:badge) }
    end
  end

  factory :messageboard_group, class: Thredded::MessageboardGroup do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
  end

  factory :post, class: Thredded::Post do
    user
    postable { association :topic, user: user, last_user: user }

    content { FakeContent.post_content }

    after :build do |post|
      post.messageboard = post.postable.messageboard
    end
  end

  factory :private_post, class: Thredded::PrivatePost do
    user
    postable { association :private_topic, user: user, last_user: user }

    content { Faker::Hacker.say_something_smart }
  end

  factory :user_preference, class: Thredded::UserPreference do
    user
  end

  factory :user_messageboard_preference, class: Thredded::UserMessageboardPreference do
    user
    messageboard
  end

  factory :messageboard_notifications_for_followed_topics,
          class: Thredded::MessageboardNotificationsForFollowedTopics do
    user
    user_preference { build(:user_preference, user: user) }
    messageboard
    notifier_key { 'email' }
  end
  factory :notifications_for_followed_topics, class: Thredded::NotificationsForFollowedTopics do
    user
    user_preference { build(:user_preference, user: user) }
    notifier_key { 'email' }
  end
  factory :notifications_for_private_topics, class: Thredded::NotificationsForPrivateTopics do
    user
    user_preference { build(:user_preference, user: user) }
    notifier_key { 'email' }
  end

  factory :topic, class: Thredded::TopicDefault do
    transient do
      with_posts { 0 }
      post_interval { 1.hour }
      with_categories { 0 }
    end

    title { Faker::Movies::StarWars.quote }
    hash_id { generate(:topic_hash) }

    user
    messageboard

    after(:create) do |topic, evaluator|
      if evaluator.with_posts
        ago = topic.updated_at - evaluator.with_posts * evaluator.post_interval
        evaluator.with_posts.times do
          ago += evaluator.post_interval
          create(:post, postable: topic, user: topic.user, messageboard: topic.messageboard, created_at: ago,
                        updated_at: ago, moderation_state: topic.moderation_state)
        end
        topic.last_user = topic.user
        topic.posts_count = evaluator.with_posts
        topic.save
      end

      evaluator.with_categories.times do
        topic.categories << create(:category)
      end
    end

    trait :locked do
      locked { true }
    end

    trait :pinned do
      sticky { true }
    end

    trait :sticky do
      sticky { true }
    end

    trait :with_badge do
      badge { create(:badge) }
    end
  end

  factory :movie, class: Thredded::TopicMovie do
    transient do
      with_posts { 0 }
      post_interval { 1.hour }
      with_categories { 0 }
    end

    title { Faker::Movies::StarWars.quote }
    hash_id { generate(:topic_hash) }

    user
    association :messageboard, :for_movies

    after(:create) do |topic, evaluator|
      if evaluator.with_posts
        ago = topic.updated_at - evaluator.with_posts * evaluator.post_interval
        evaluator.with_posts.times do
          ago += evaluator.post_interval
          create(:post, postable: topic, user: topic.user, messageboard: topic.messageboard, created_at: ago,
                        updated_at: ago, moderation_state: topic.moderation_state)
        end
        topic.last_user = topic.user
        topic.posts_count = evaluator.with_posts
        topic.save
      end

      evaluator.with_categories.times do
        topic.categories << create(:category)
      end
    end

    trait :locked do
      locked { true }
    end

    trait :pinned do
      sticky { true }
    end

    trait :sticky do
      sticky { true }
    end
  end

  factory :private_topic, class: Thredded::PrivateTopic do
    transient do
      with_posts { 0 }
      post_interval { 1.hour }
    end
    user
    users { [user] + build_list(:user, rand(1..3)) }

    title { Faker::Lorem.sentence[0..-2] }
    hash_id { generate(:topic_hash) }

    after :create do |topic, evaluator|
      if evaluator.with_posts
        ago = topic.updated_at - evaluator.with_posts * evaluator.post_interval
        last_user = nil
        evaluator.with_posts.times do |i|
          ago += evaluator.post_interval
          user = i == 0 ? topic.user : topic.users.sample
          last_user = user
          create(:private_post, postable: topic, user: user, created_at: ago, updated_at: ago)
        end
        topic.last_user = last_user
        topic.posts_count = evaluator.with_posts
        topic.save
      end
    end
  end

  factory :private_user, class: Thredded::PrivateUser do
    private_topic
    user
  end

  factory :user, aliases: %i[email_confirmed_user last_user], class: ::User do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { [true, false].sample ? Faker::Name.name : Faker::Name.first_name }

    trait :admin do
      admin { true }
      after(:create) do |user, _|
        user.thredded_user_detail.save!
      end
    end

    trait :with_user_details do
      after(:create) do |user, _|
        user.thredded_user_detail.save!
      end
    end

    trait :approved do
      after(:create) do |user, _|
        user.thredded_user_detail.update!(moderation_state: :approved)
      end
    end

    trait :blocked do
      after(:create) do |user, _|
        user.thredded_user_detail.update!(moderation_state: :blocked)
      end
    end
  end

  factory :user_detail, class: Thredded::UserDetail do
    user
  end

  factory :user_topic_read_state, class: Thredded::UserTopicReadState do
    user
    association :postable, factory: :topic
    read_at { Time.now.utc }
    after :build do |read_state|
      read_state.messageboard = read_state.postable.messageboard
      read_state.assign_attributes(read_state.calculate_post_counts)
    end
  end

  factory :user_private_topic_read_state, class: Thredded::UserPrivateTopicReadState do
    user
    association :postable, factory: :private_topic
    read_at { Time.now.utc }
    after :build do |read_state|
      read_state.assign_attributes(read_state.calculate_post_counts)
    end
  end

  factory :user_topic_follow, class: Thredded::UserTopicFollow do
    user
    topic
  end

  factory :badge, class: Thredded::Badge do
    sequence(:title) { |n| "badge#{n}" }
    description { 'This is a description of the badge' }

    trait :secret do
      secret { true }
    end
  end

  factory :notification, class: Thredded::Notification do
    sequence(:name) { |n| "notification#{n}" }
    description { 'This is a description of the notification' }
    url { 'https://dev.brickboard.de/' }
    user
  end
end
