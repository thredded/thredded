require 'spec_helper'

module Thredded
  describe Messageboard do
    it { should have_db_column(:closed) }
    it { should have_db_index(:closed) }
    it { should have_many(:messageboard_preferences) }
    it { should have_db_column(:filter) }
    it { should validate_presence_of(:filter) }
    it { should ensure_inclusion_of(:filter).in_array(['markdown', 'bbcode']) }

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

    describe '#preferences_for' do
      it 'creates a new preference if it does not exist already' do
        messageboard = create(:messageboard)
        user = create(:user)

        expect(messageboard.preferences_for user).not_to be_nil
        expect(messageboard.preferences_for user).to be_persisted
      end

      it 'finds an existing preference' do
        messageboard = create(:messageboard)
        user = create(:user)
        prefs = create(:messageboard_preference,
          messageboard: messageboard, user: user)

        expect(messageboard.preferences_for user).to eq prefs
      end
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

  describe Messageboard, '#active_users' do
    it 'returns users active for a messageboard' do
      messageboard = create(:messageboard)
      active_user = create(:user)
      inactive_user = create(:user)

      create(:role, :active, user: active_user, messageboard: messageboard)
      create(:role, :inactive, user: inactive_user, messageboard: messageboard)

      expect(messageboard.active_users).to eq [active_user]
    end
  end

  describe Messageboard, '#update_activity_for' do
    it "updates a user's activity for a messageboard" do
      messageboard = create(:messageboard)
      inactive_user = create(:user)
      create(:role, :inactive, user: inactive_user, messageboard: messageboard)

      messageboard.update_activity_for!(inactive_user)

      expect(messageboard.active_users).to include inactive_user
    end

    it "updates nothing if no role exists" do
      messageboard = create(:messageboard)
      user = create(:user)

      expect{ messageboard.update_activity_for!(user) }.not_to raise_error
    end
  end
end
