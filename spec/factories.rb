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
    filter 'markdown'
    closed false

    trait :bbcode do
      filter 'bbcode'
    end

    trait :markdown do
      filter 'markdown'
    end
  end

  factory :post, aliases: [:farthest_post], class: Thredded::Post do
    user
    association :postable, factory: :topic
    messageboard

    content { Faker::Hacker.say_something_smart }
    ip '127.0.0.1'
    filter 'markdown'

    trait :markdown do
      filter 'markdown'
    end

    trait :bbcode do
      before(:create) do |post, _|
        post.messageboard.update_attributes(filter: 'bbcode')
      end
    end
  end

  factory :private_post, class: Thredded::PrivatePost do
    user
    association :postable, factory: :private_topic

    content { Faker::Hacker.say_something_smart }
    ip '127.0.0.1'
    filter 'markdown'
  end

  factory :post_notification, class: Thredded::PostNotification do
    email 'someone@example.com'

    post
  end

  factory :notification_preference, class: Thredded::NotificationPreference do
    user
    messageboard

    notify_on_mention false
    notify_on_message false
  end

  factory :topic, class: Thredded::Topic do
    transient do
      with_posts 0
      with_categories 0
    end

    title { Faker::Lorem.sentence[0..-2] }
    hash_id { generate(:topic_hash) }

    user
    messageboard
    association :last_user, factory: :user

    after(:create) do |topic, evaluator|
      if evaluator.with_posts
        evaluator.with_posts.times do
          create(:post, postable: topic, user: topic.user, messageboard: topic.messageboard)
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
        create(:user_detail, user: user)
      end
    end

    trait :with_user_details do
      after(:create) do |user, _|
        create(:user_detail, user: user)
      end
    end
  end

  factory :user_detail, class: Thredded::UserDetail do
    user
  end

  factory :user_topic_read, class: Thredded::UserTopicRead do
    user
    topic
    farthest_post
    page 1
  end
end
