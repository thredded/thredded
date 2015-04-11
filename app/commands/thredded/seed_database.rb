require_relative '../../../spec/factories' unless FactoryGirl.factories.instance_variable_get(:@items).any?

module Thredded
  class SeedDatabase
    include FactoryGirl::Syntax::Methods

    attr_reader :user, :messageboard

    def self.run
      new.run
    end

    def run
      @user ||= begin
        ::User.first ||
          ::User.create(name: 'joe', email: 'joe@example.com')
      end

      @messageboard = create(
        :messageboard,
        name: 'Theme Test',
        slug: 'theme-test',
        description: 'A theme is not a theme without some test data'
      )

      topics = create_list(
        :topic, 3,
        messageboard: messageboard,
        user: user,
        last_user: user
      )

      private_topics = create_list(
        :private_topic, 3,
        messageboard: messageboard,
        user: user,
        last_user: user,
        users: [user]
      )

      create(:post, postable: topics[0], messageboard: messageboard, user: user)
      create(:post, postable: topics[1], messageboard: messageboard, user: user)
      create(:post, postable: topics[2], messageboard: messageboard, user: user)

      create(:post, postable: private_topics[0], messageboard: messageboard, user: user)
      create(:post, postable: private_topics[1], messageboard: messageboard, user: user)
      create(:post, postable: private_topics[2], messageboard: messageboard, user: user)

      john = create(:user, name: 'john')
      fred = create(:user, name: 'fred')
      kyle = create(:user, name: 'kyle')

      create(:role, user: john, messageboard: messageboard)
      create(:role, user: fred, messageboard: messageboard)
      create(:role, user: kyle, messageboard: messageboard)
      create(:role, user: user, messageboard: messageboard)
    end
  end
end
