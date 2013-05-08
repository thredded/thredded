require 'spec_helper'
require 'cancan/matchers'

module Thredded
describe User, 'abilities' do
  context 'for a private messageboard' do
    it 'allows a member to view it' do
      user = build_stubbed(:user)
      messageboard = build_stubbed(:messageboard, :private)
      user.stubs(member_of?: true)
      ability = Ability.new(user)

      ability.should be_able_to(:read, messageboard)
    end

    it 'does not allow a non-members to view it' do
      user = build_stubbed(:user)
      messageboard = build_stubbed(:messageboard, :private)
      user.stubs(member_of?: false)
      ability = Ability.new(user)

      ability.should_not be_able_to(:read, messageboard)
    end
  end

  context 'for a public site' do
    it 'allows any user' do
      ability = Ability.new(User.new)
      site = build_stubbed(:site, permission: 'public')
      ability.should be_able_to(:read, site)
    end
  end

  context 'for a site that requires users to log in' do
    it 'allows a logged in user' do
      ability = Ability.new(build_stubbed(:user))
      site = build_stubbed(:site, permission: 'logged_in')
      ability.should be_able_to(:read, site)
    end

    it 'does not allow an anonymous user' do
      ability = Ability.new(User.new)
      site = build_stubbed(:site, permission: 'logged_in')
      ability.should_not be_able_to(:read, site)
    end
  end


  context 'for a topic' do
    it 'allows a user to read it' do
      ability = Ability.new(build_stubbed(:user))
      topic = build_stubbed(:topic)
      ability.should be_able_to(:read, topic)
    end

    context 'in a messageboard with logged_in permissions' do
      before(:each) do
        @user = create(:user)
        @messageboard = create(:messageboard)
        @topic  = create(:topic, security: 'logged_in',
          messageboard: @messageboard)
      end

      it 'is not readable by anonymous visitors' do
        @user = Thredded::NullUser.new
        ability = Ability.new(@user)
        ability.can?(:read, @topic).should be_false
      end

      it 'is readable by a logged in user' do
        ability = Ability.new(@user)
        ability.can?(:read, @topic).should be_true
      end
    end

    context 'in a private messageboard' do
      before do
        @messageboard = build_stubbed(:messageboard, security: 'private')
        @topic = build_stubbed(:topic, messageboard: @messageboard)
        @user = build_stubbed(:user)
      end

      it 'allows a member to create a topic' do
        @user.stubs(:member_of?).returns(true)
        ability = Ability.new(@user)
        ability.should be_able_to(:create, @topic)
      end

      it 'allows a member to read a topic' do
        @user.stubs(:member_of?).returns(true)
        ability = Ability.new(@user)
        ability.should be_able_to(:read, @topic)
      end

      it 'does not allow a non-member to read a topic' do
        @user.stubs(:member_of?).returns(false)
        ability = Ability.new(@user)
        ability.should_not be_able_to(:read, @topic)
      end

      it 'does not allow a non-member to create a topic' do
        @user.stubs(:member_of?).returns(false)
        ability = Ability.new(@user)
        ability.should_not be_able_to(:create, @topic)
      end

      it 'does not allow a logged in user to create a topic' do
        @user.stubs(:member_of?).returns(false)
        ability = Ability.new(@user)
        ability.should_not be_able_to(:create, @topic)
      end

      it 'does not allow a logged in user to read a topic' do
        @user.stubs(:member_of?).returns(false)
        ability = Ability.new(@user)
        ability.should_not be_able_to(:create, @topic)
      end

      it 'does not allow a logged in user to list topics' do
        @user.stubs(:member_of?).returns(false)
        ability = Ability.new(@user)
        ability.should_not be_able_to(:index, @topic)
      end

      it 'does not allow anonymous to create a topic' do
        @user = User.new
        ability = Ability.new(@user)
        ability.should_not be_able_to(:create, @topic)
      end

      it 'does not allow anonymous to read a topic' do
        @user = User.new
        ability = Ability.new(@user)
        ability.should_not be_able_to(:read, @topic)
      end
    end
  end

  context 'for a private topic' do
    it 'allows an involved user to read it' do
      user = build_stubbed(:user)
      ability = Ability.new(user)
      private_topic = build_stubbed(:private_topic, users: [user])
      ability.should be_able_to(:read, private_topic)
    end

    it 'does not allow a random user to read it' do
      random_user = build_stubbed(:user, name: 'joe')
      user = build_stubbed(:user)
      ability = Ability.new(random_user)
      private_topic = build_stubbed(:private_topic, users: [user])
      ability.should_not be_able_to(:read, private_topic)
    end

    it 'does not allow an admin to read it' do
      user = build_stubbed(:user)
      admin = build_stubbed(:user)
      admin.stubs(:admins?).returns(true)
      ability = Ability.new(admin)
      private_topic = build_stubbed(:private_topic, users: [user])

      ability.should_not be_able_to(:manage, private_topic)
      ability.should_not be_able_to(:read, private_topic)
    end
  end
end
