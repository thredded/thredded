require 'spec_helper'

module Thredded
  describe Messageboard, 'associations' do
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:notification_preferences).dependent(:destroy) }
    it { should have_many(:posts).dependent(:destroy) }
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
      closed     = create(:messageboard, closed: true)
      all_boards = Messageboard.all

      expect(all_boards).to include(@messageboard)
      expect(all_boards).not_to include(closed)
    end

    it 'orders by number of topics, descending' do
      create(:messageboard, topics_count: 500)
      lots       = create(:messageboard, topics_count: 1000)
      all_boards = Messageboard.all

      expect(all_boards.first).to eq lots
      expect(all_boards.last).to eq @messageboard
    end

    describe '#preferences_for' do
      it 'creates a new preference if it does not exist already' do
        messageboard = create(:messageboard)
        user         = create(:user)

        expect(messageboard.preferences_for user).not_to be_nil
        expect(messageboard.preferences_for user).to be_persisted
      end

      it 'finds an existing preference' do
        messageboard = create(:messageboard)
        user         = create(:user)
        prefs        = create(:notification_preference,
                              messageboard: messageboard, user: user)

        expect(messageboard.preferences_for user).to eq prefs
      end
    end

    describe '#recently_active_users' do
      it 'returns users active for a messageboard' do
        messageboard   = create(:messageboard)
        active_user    = create(:user)
        _inactive_user = create(:user)
        Thredded::ActivityUpdaterJob.perform_later(
          active_user.id,
          messageboard.id
        )

        expect(messageboard.recently_active_users).to eq [active_user]
      end
    end

    describe '.find_by_slug' do
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
end
