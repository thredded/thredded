# frozen_string_literal: true
require 'faker'
I18n.reload!
include ActionDispatch::TestProcess

FactoryGirl.define do
  sequence(:topic_hash) { |n| "hash#{n}" }

  factory :email, class: OpenStruct do
    to 'email-token'
    from 'user@email.com'
    subject 'email subject'
    body 'Hello!'
  end

  factory :category, class: Thredded::Category do
    sequence(:name) { |n| "category#{n}" }
    sequence(:description) { |n| "Category #{n}" }
    messageboard

    trait :beer do
      name 'beer'
      description 'a delicious adult beverage'
    end
  end

  factory :messageboard, class: Thredded::Messageboard do
    sequence(:name) { |n| "messageboard#{n}" }
    description 'This is a description of the messageboard'
    closed false
  end

  factory :messageboard_group, class: Thredded::MessageboardGroup do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
  end

  factory :post, class: Thredded::Post do
    user
    postable { association :topic, user: user }

    content { Faker::Hacker.say_something_smart }
    ip '127.0.0.1'

    after :build do |post|
      post.messageboard = post.postable.messageboard
    end
  end

  factory :private_post, class: Thredded::PrivatePost do
    user
    postable { association :private_topic, user: user }

    content { Faker::Hacker.say_something_smart }
    ip '127.0.0.1'
  end

  factory :post_notification, class: Thredded::PostNotification do
    email 'someone@example.com'

    post
  end

  factory :user_preference, class: Thredded::UserPreference do
    user
  end

  factory :user_messageboard_preference, class: Thredded::UserMessageboardPreference do
    user
    messageboard
  end

  factory :topic, class: Thredded::Topic do
    transient do
      with_posts 0
      post_interval 1.hour
      with_categories 0
    end

    title { Faker::StarWars.quote }
    hash_id { generate(:topic_hash) }

    user
    messageboard
    association :last_user, factory: :user

    after(:create) do |topic, evaluator|
      if evaluator.with_posts
        ago = topic.updated_at - evaluator.with_posts * evaluator.post_interval
        evaluator.with_posts.times do
          ago += evaluator.post_interval
          create(:post, postable: topic, user: topic.user, messageboard: topic.messageboard, created_at: ago,
                        updated_at: ago, moderation_state: topic.moderation_state)
        end

        topic.posts_count = evaluator.with_posts
        topic.save
      end

      evaluator.with_categories.times do
        topic.categories << create(:category)
      end
    end

    trait :locked do
      locked true
    end

    trait :pinned do
      sticky true
    end

    trait :sticky do
      sticky true
    end
  end

  factory :private_topic, class: Thredded::PrivateTopic do
    user
    users { build_list :user, 1 }
    association :last_user, factory: :user

    title { Faker::Lorem.sentence[0..-2] }
    hash_id { generate(:topic_hash) }
  end

  factory :private_user, class: Thredded::PrivateUser do
    private_topic
    user
  end

  factory :user, aliases: [:email_confirmed_user, :last_user], class: ::User do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }

    trait :admin do
      admin true
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
    page 1
  end
  factory :user_private_topic_read_state, class: Thredded::UserPrivateTopicReadState do
    user
    association :postable, factory: :private_topic
    page 1
    read_at { Time.now.utc }
  end

  factory :user_topic_follow, class: Thredded::UserTopicFollow do
    user
    topic
  end
end
