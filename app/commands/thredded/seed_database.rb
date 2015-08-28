# rubocop:disable HandleExceptions
begin
  if FactoryGirl.factories.instance_variable_get(:@items).none?
    require_relative '../../../spec/factories'
  end
rescue NameError
end
# rubocop:enable HandleExceptions

module Thredded
  class SeedDatabase
    attr_reader :user, :users, :messageboard, :topics, :private_topics, :posts

    def self.run(users: 5, topics: 26, posts: (0..20))
      s = new
      s.create_messageboard
      s.create_first_user
      s.create_users(count: users)
      s.create_topics(count: topics)
      s.create_posts(count: posts)
    end

    def create_first_user
      @user ||= begin
        ::User.first ||
          ::User.create(name: 'joe', email: 'joe@example.com')
      end
    end

    def create_users(count: 5)
      @users = [user] + FactoryGirl.create_list(:user, count)
    end

    def create_messageboard
      @messageboard = FactoryGirl.create(
        :messageboard,
        name:        'Main Board',
        slug:        'main-board',
        description: 'A board is not a board without some posts'
      )
    end

    def create_topics(count: 26)
      @topics = FactoryGirl.create_list(
        :topic, count,
        messageboard: messageboard,
        user:         users.sample,
        last_user:    users.sample)

      @private_topics = FactoryGirl.create_list(
        :private_topic, count,
        messageboard: messageboard,
        user:         users.sample,
        last_user:    users.sample,
        users:        [user])
    end

    def create_posts(count: (0..30))
      @posts = (topics + private_topics).flat_map do |topic|
        (count.min + rand(count.max + 1)).times { FactoryGirl.create(:post, postable: topic, messageboard: messageboard, user: users.sample) }
      end
    end
  end
end
