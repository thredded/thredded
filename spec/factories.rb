include ActionDispatch::TestProcess

FactoryGirl.define do
  sequence(:topic_hash) { |n| "hash#{n}" }

  factory :email, class: OpenStruct do
    to 'email-token'
    from 'user@email.com'
    subject 'email subject'
    body 'Hello!'
    attachments {[]}

    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/samples/img.png")
        })
      ]}
    end

    trait :with_attachments do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/samples/img.png")
        }),
        ActionDispatch::Http::UploadedFile.new({
          filename: 'zip.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/samples/zip.png")
        })
      ]}
    end
  end

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
    filter 'markdown'
    posting_permission  'anonymous'
    security 'public'

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

    trait :bbcode do
      filter 'bbcode'
    end

    trait :markdown do
      filter 'markdown'
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

    trait :active do
      last_seen Time.now
    end

    trait :inactive do
      last_seen 3.days.ago
    end
  end

  factory :post, aliases: [:farthest_post], class: Thredded::Post do
    user
    topic
    messageboard

    sequence(:content) { |n| "A post about the number #{n}" }
    ip '127.0.0.1'
    filter 'markdown'

    trait :markdown do
      filter 'markdown'
    end

    trait :bbcode do
      before(:create) do |post, evaluator|
        post.messageboard.update_attributes(filter: 'bbcode')
      end
    end
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
      if evaluator.with_posts
        topic.posts_count = evaluator.with_posts
        topic.save
      end

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

    trait :admin do
      after(:create) do |user, evaluator|
        Thredded::Messageboard.all.each do |messageboard|
          messageboard.add_member(user, 'admin')
        end
      end
    end

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
  end

  factory :user_detail, class: Thredded::UserDetail

  factory :user_topic_read, class: Thredded::UserTopicRead do
    user
    topic
    farthest_post
    page 1
  end
end
