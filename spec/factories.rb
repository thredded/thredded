include ActionDispatch::TestProcess

FactoryGirl.define do
  sequence(:topic_hash) { |n| "hash#{n}" }

  factory :attachment, class: Thredded::Attachment do
    attachment    { fixture_file_upload('spec/samples/img.png', 'image/png') }
    content_type  'image/png'
    file_size     1000

    factory :imgpng

    factory :pdfpng do
      attachment  { fixture_file_upload('spec/samples/pdf.png', 'image/png') }
    end

    factory :txtpng do
      attachment  { fixture_file_upload('spec/samples/txt.png', 'image/png') }
    end

    factory :zippng do
      attachment  { fixture_file_upload('spec/samples/zip.png', 'image/png') }
    end
  end

  factory :category, class: Thredded::Category do
    sequence(:name) { |n| "category#{n}" }
    sequence(:description) { |n| "Category #{n}" }

    trait :beer do
      name 'beer'
      description 'a delicious adult beverage'
    end

    trait :with_messageboard do
      messageboard
    end
  end

  factory :messageboard, class: Thredded::Messageboard do
    sequence(:name) { |n| "messageboard#{n}" }
    description 'This is a description of the messageboard'
    security 'public'
    posting_permission  'anonymous'

    trait :postable_for_logged_in do
      posting_permission 'logged_in'
    end

    trait :restricted_to_logged_in do
      security 'logged_in'
    end

    trait :private do
      security 'private'
    end

    trait :public do
      security 'public'
    end
  end

  factory :role, class: Thredded::Role do
    level 'member'
    user

    trait :admin do
      level 'admin'
    end

    trait :superadmin do
      level 'superadmin'
    end

    trait :moderator do
      level 'moderator'
    end

    trait :member do
      level 'member'
    end

    trait :inactive do
      last_seen 3.days.ago
    end
  end

  factory :post, class: Thredded::Post do
    user
    topic
    messageboard

    sequence(:content) { |n| "A post about the number #{n}" }
    ip '127.0.0.1'
    filter 'bbcode'
  end

  factory :post_notification, class: Thredded::PostNotification

  factory :messageboard_preference, class: Thredded::MessageboardPreference do
    notify_on_mention false
    notify_on_message false
  end

  factory :topic, class: Thredded::Topic do
    ignore do
      with_posts 0
      with_categories 0
    end

    user
    messageboard
    association :last_user, factory: :user

    title 'New topic started here'
    hash_id { generate(:topic_hash) }

    after(:create) do |topic, evaluator|
      evaluator.with_posts.times do
        create(:post, topic: topic, messageboard: topic.messageboard)
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
    messageboard
    association :last_user, factory: :user

    title 'New private topic started here'
    hash_id { generate(:topic_hash) }
  end

  factory :user, aliases: [:email_confirmed_user, :last_user], class: ::User do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "name#{n}" }

    trait :with_user_details do
      after(:create) do |user, evaluator|
        create(:user_detail, user: user)
      end
    end

    trait :superadmin do
      after(:create) do |user, evaluator|
        create(:user_detail, user: user, superadmin: true)
      end
    end

    trait :prefers_bbcode do
      after(:create) do |user, evaluator|
        Thredded::Messageboard.all.each do |messageboard|
          create(:messageboard_preference,
            filter: 'bbcode',
            user: user,
            messageboard: messageboard,
          )
        end
      end
    end

    trait :prefers_markdown do
      after(:create) do |user, evaluator|
        Thredded::Messageboard.all.each do |messageboard|
          create(:messageboard_preference,
            filter: 'markdown',
            user: user,
            messageboard: messageboard,
          )
        end
      end
    end
  end

  factory :user_detail, class: Thredded::UserDetail

  factory :user_topic_read, class: Thredded::UserTopicRead do
    user_id 1
    topic_id 1
    post_id 1
    page 1
  end
end
