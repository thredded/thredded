require 'spec_helper'

module Thredded
  describe Messageboard do
    it { should have_db_column(:closed) }
    it { should have_db_index(:closed) }
    it { should have_many(:messageboard_preferences) }

    before(:each) do
      @messageboard = create(:messageboard, topics_count: 10)
    end

    it 'returns only open messageboards' do
      closed = create(:messageboard, closed: true)
      all_boards = Messageboard.all

      all_boards.should include(@messageboard)
      all_boards.should_not include(closed)
    end

    it 'orders by number of topics, descending' do
      meh = create(:messageboard, topics_count: 500)
      lots = create(:messageboard, topics_count: 1000)
      all_boards = Messageboard.all

      all_boards.first.should eq lots
      all_boards.last.should eq @messageboard
    end

    describe '.add_member' do
      it 'creates a membership role for a provided user' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user)
        role = Thredded::Role.first

        role.messageboard.should eq messageboard
        role.user.should eq user
        role.level.should eq 'member'
      end

      it 'assigns a user as an admin for this board' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'admin')
        role = Thredded::Role.first

        role.messageboard.should eq messageboard
        role.user.should eq user
        role.level.should eq 'admin'
      end
    end

    describe '#has_member?' do
      it 'is true if a user is a member of a messageboard' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user)

        messageboard.has_member?(user).should be_true
      end

      it 'is false if user is not a member' do
        user = create(:user)
        messageboard = create(:messageboard)

        messageboard.has_member?(user).should be_false
      end
    end

    describe '#member_is_a?' do
      it 'is true when checking that an admin is an admin' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'admin')

        messageboard.member_is_a?(user, 'admin').should be_true
      end

      it 'is false when checking that a member is an admin' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'member')

        messageboard.member_is_a?(user, 'admin').should_not be_true
      end
    end

    describe '.active_users' do
      xit 'returns a list of users active in this messageboard' do
        john = create(:user, name: 'John')
        joe  = create(:user, name: 'Joe')
        john.member_of @messageboard
        joe.member_of @messageboard
        john.mark_active_in!(@messageboard)
        joe.mark_active_in!(@messageboard)

        @messageboard.active_users[0].name.should eq 'Joe'
        @messageboard.active_users[1].name.should eq 'John'
      end
    end

    describe '#restricted_to_private?' do
      it 'checks whether a messageboard is private and restricted to members' do
        @messageboard.security = 'private'
        @messageboard.restricted_to_private?.should be_true
      end
    end

    describe '#restricted_to_logged_in?' do
      it 'checks whether a messageboard is restricted to only those that are logged in' do
        @messageboard.security = 'logged_in'
        @messageboard.restricted_to_logged_in?.should be_true
      end
    end

    describe '#public?' do
      it 'checks whether a messageboard is open for all to read' do
        @messageboard.security = 'public'
        @messageboard.public?.should be_true
      end
    end
  end

  describe Messageboard, '#members_from_list' do
    it 'returns members from array of case-insensitive strings (usernames)' do
      board = create(:messageboard)
      joel = create(:user, name: 'Joel')
      steve = create(:user, name: 'steve')
      john = create(:user, name: 'john')
      board.add_member(joel)
      board.add_member(steve)
      board_members_from_list = board.members_from_list(%w(joel Steve john))

      board_members_from_list.should include(joel)
      board_members_from_list.should include(steve)
      board_members_from_list.should_not include(john)
    end
  end
end
