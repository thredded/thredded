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
    attr_reader :user, :messageboard

    def self.run
      new.run
    end

    def run
      @user ||= begin
        ::User.first ||
          ::User.create(name: 'joe', email: 'joe@example.com')
      end

      john = FactoryGirl.create(:user, name: 'john')
      fred = FactoryGirl.create(:user, name: 'fred')
      kyle = FactoryGirl.create(:user, name: 'kyle')

      @messageboard = FactoryGirl.create(
        :messageboard,
        name: 'Theme Test',
        slug: 'theme-test',
        description: 'A theme is not a theme without some test data'
      )

      topics = FactoryGirl.create_list(
        :topic, 3,
        messageboard: messageboard,
        user: user,
        last_user: user
      )

      private_topics = FactoryGirl.create_list(
        :private_topic, 3,
        messageboard: messageboard,
        user: user,
        last_user: user,
        users: [user]
      )

      FactoryGirl.create(:post, postable: topics[0], messageboard: messageboard, user: user)
      FactoryGirl.create(:post, postable: topics[1], messageboard: messageboard, user: user)
      FactoryGirl.create(:post, postable: topics[2], messageboard: messageboard, user: user)

      FactoryGirl.create(:post, postable: private_topics[0], messageboard: messageboard, user: user)
      FactoryGirl.create(:post, postable: private_topics[1], messageboard: messageboard, user: user)
      FactoryGirl.create(:post, postable: private_topics[2], messageboard: messageboard, user: user)

      FactoryGirl.create(:role, user: user, messageboard: messageboard)
      FactoryGirl.create(:role, user: kyle, messageboard: messageboard)
      FactoryGirl.create(:role, user: john, messageboard: messageboard)
      FactoryGirl.create(:role, user: fred, messageboard: messageboard)

      self
    end
  end
end
