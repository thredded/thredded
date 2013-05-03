require 'spec_helper'

module Thredded
  describe Messageboard do
    it { should have_db_column(:closed) }
    it { should have_db_index(:closed) }
    it { should have_many(:preferences) }

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

    describe '.has_member?' do
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

    describe '.postable_by?' do
      describe 'for public boards' do
        it 'should be true if allows anonymous' do
          @messageboard.security = 'public'
          @messageboard.postable_by?(@current_user).should be_true
        end

        it 'should be false if for logged_in' do
          user = create(:user)
          @messageboard.security = 'public'
          @messageboard.postable_by?(user).should be_true
        end

        it 'should be false if for members' do
          user = create(:user)
          @messageboard.security = 'public'
          @messageboard.add_member(user)
          @messageboard.postable_by?(user).should be_true
        end
      end

      describe 'for logged_in boards' do
        it 'should be false if anonymous and allows anonymous posting' do
          @messageboard.security = 'logged_in'
          @messageboard.postable_by?(@current_user).should be_false
        end

        it 'should be true if logged in and allows logged_in posting' do
          user = create(:user)
          @messageboard.security = 'logged_in'
          @messageboard.posting_permission = 'logged_in'
          @messageboard.postable_by?(user).should be_true
        end

        it 'should be true if a member and allows logged_in posting' do
          user = create(:user)
          @messageboard.security = 'logged_in'
          @messageboard.posting_permission = 'logged_in'
          @messageboard.add_member(user)
          @messageboard.postable_by?(user).should be_true
        end
      end

      describe 'for private boards' do
        it 'should be false if anonymous and allows anonymous' do
          @messageboard.security = 'private'
          @messageboard.postable_by?(@current_user).should be_false
        end

        it 'should be false if user is not a member and posting permission is logged in' do
          user = create(:user)
          @messageboard.security = 'private'
          @messageboard.posting_permission = 'members'
          @messageboard.postable_by?(user).should be_false
        end

        it 'should be true if a member and allows member posting' do
          user = create(:user)
          @messageboard.security = 'private'
          @messageboard.posting_permission = 'members'
          @messageboard.add_member(user)
          @messageboard.postable_by?(user).should be_true
        end
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
