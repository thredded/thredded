require_relative '../../../spec/factories'

module Thredded
  class SeedDatabase
    include FactoryGirl::Syntax::Methods

    def self.run
      new.run
    end

    def run
      board = create(
        :messageboard,
        name: 'Theme Test',
        slug: 'theme-test',
        description: 'A theme is not a theme without some test data'
      )

      topics = create_list(
        :topic, 3,
        messageboard: board,
        user: user,
        last_user: user
      )

      private_topics = create_list(
        :private_topic, 3,
        messageboard: board,
        user: user,
        last_user: user,
        users: [user]
      )

      create(:post, postable: topics[0], messageboard: board, user: user)
      create(:post, postable: topics[1], messageboard: board, user: user)
      create(:post, postable: topics[2], messageboard: board, user: user)

      create(:post, postable: private_topics[0], messageboard: board, user: user)
      create(:post, postable: private_topics[1], messageboard: board, user: user)
      create(:post, postable: private_topics[2], messageboard: board, user: user)
    end

    private

    def user
      @user ||= begin
        ::User.first ||
          ::User.create(name: 'joe', email: 'joe@example.com')
      end
    end
  end
end
