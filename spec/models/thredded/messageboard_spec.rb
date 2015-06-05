require 'spec_helper'

module Thredded
  describe Messageboard, 'associations' do
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:messageboard_preferences).dependent(:destroy) }
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:private_topics).dependent(:destroy) }
    it { should have_many(:roles).dependent(:destroy) }
    it { should have_many(:topics).dependent(:destroy) }
  end

  describe Messageboard, 'validations' do
    it { should validate_presence_of(:filter) }
    it { should validate_presence_of(:name) }
  end

  describe Messageboard do
    it { should have_db_column(:closed) }
    it { should have_db_index(:closed) }
    it { should have_db_index(:slug) }
    it { should have_db_column(:filter) }
    it { should validate_inclusion_of(:filter).in_array(%w(markdown bbcode)) }

    before(:each) do
      @messageboard = create(:messageboard, topics_count: 10)
    end

    it 'generates the slug' do
      messageboard = create(:messageboard, name: 'Super Friends')

      expect(messageboard.slug).to eq 'super-friends'
    end

    it 'returns only open messageboards' do
      closed = create(:messageboard, closed: true)
      all_boards = Messageboard.all

      expect(all_boards).to include(@messageboard)
      expect(all_boards).not_to include(closed)
    end

    it 'orders by number of topics, descending' do
      create(:messageboard, topics_count: 500)
      lots = create(:messageboard, topics_count: 1000)
      all_boards = Messageboard.all

      expect(all_boards.first).to eq lots
      expect(all_boards.last).to eq @messageboard
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

        expect(role.messageboard).to eq messageboard
        expect(role.user).to eq user
        expect(role.level).to eq 'member'
      end

      it 'assigns a user as an admin for this board' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'admin')
        role = Thredded::Role.first

        expect(role.messageboard).to eq messageboard
        expect(role.user).to eq user
        expect(role.level).to eq 'admin'
      end
    end

    describe '#member?' do
      it 'is true if a user is a member of a messageboard' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user)

        expect(messageboard.member?(user)).to be_truthy
      end

      it 'is false if user is not a member' do
        user = create(:user)
        messageboard = create(:messageboard)

        expect(messageboard.member?(user)).to be_falsy
      end
    end

    describe '#member_is_a?' do
      it 'is true when checking that an admin is an admin' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'admin')

        expect(messageboard.member_is_a?(user, 'admin')).to be_truthy
      end

      it 'is false when checking that a member is an admin' do
        user = create(:user)
        messageboard = create(:messageboard)
        messageboard.add_member(user, 'member')

        expect(messageboard.member_is_a?(user, 'admin')).not_to be_truthy
      end
    end

    describe '#restricted_to_private?' do
      it 'checks whether a messageboard is private and restricted to members' do
        @messageboard.security = 'private'
        expect(@messageboard.restricted_to_private?).to eq true
      end
    end

    describe '#restricted_to_logged_in?' do
      it 'checks whether a messageboard is restricted to only those that are logged in' do
        @messageboard.security = 'logged_in'
        expect(@messageboard.restricted_to_logged_in?).to eq true
      end
    end

    describe '#public?' do
      it 'checks whether a messageboard is open for all to read' do
        @messageboard.security = 'public'
        expect(@messageboard.public?).to eq true
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

      expect(board_members_from_list).to include(joel)
      expect(board_members_from_list).to include(steve)
      expect(board_members_from_list).not_to include(john)
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

  describe Messageboard, '.find_by_slug' do
    it 'finds the messageboard according to the slug' do
      messageboard = create(:messageboard, name: 'A messageboard')

      expect(Messageboard.find_by_slug('a-messageboard')).to eq messageboard
    end

    context 'when a messageboard is not found' do
      it 'returns nil' do
        expect(Messageboard.find_by_slug('rubbish')).to eq nil
      end
    end
  end
end
