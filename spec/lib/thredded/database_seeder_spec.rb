# frozen_string_literal: true

require 'spec_helper'
require 'thredded/database_seeder'

describe Thredded::DatabaseSeeder do
  before { allow_any_instance_of(Thredded::DatabaseSeeder).to receive(:log) } # rubocop:disable RSpec/AnyInstance

  describe 'run' do
    subject(:seeder_run) { described_class.run(users: 2, topics: 1, posts: (1..1)) }

    it 'creates' do
      expect { seeder_run }
        .to change(User, :count).and change { Thredded::Topic.count }.and change { Thredded::Messageboard.count }
    end
  end

  context 'for' do
    around { |ex| Thredded::DatabaseSeeder.with_seeder_tweaks(&ex) }

    let(:seed_database) { Thredded::DatabaseSeeder.new }

    describe Thredded::DatabaseSeeder::Users do
      subject(:users_seeder) { Thredded::DatabaseSeeder::Users.new(seed_database) }

      it 'can be created' do
        expect { users_seeder.find_or_create }.to change(User, :count)
      end

      it 'can be retrieved' do
        user = create(:user)
        expect { expect(users_seeder.find_or_create).to eq([user]) }.not_to change(User, :count)
      end
    end

    describe Thredded::DatabaseSeeder::Topics do
      subject(:topics_seeder) { Thredded::DatabaseSeeder::Topics.new(seed_database) }

      it 'can be created' do
        expect { topics_seeder.find_or_create }.to change { Thredded::Topic.count }
      end

      it 'can be retrieved' do
        topic = create(:topic)
        expect { expect(topics_seeder.find_or_create).to eq([topic]) }.not_to change { Thredded::Topic.count }
      end
    end

    describe Thredded::DatabaseSeeder::Posts do
      subject(:posts_seeder) { Thredded::DatabaseSeeder::Posts.new(seed_database) }

      it 'can be created' do
        expect { posts_seeder.find_or_create }.to change { Thredded::Post.count }
      end

      it 'can be retrieved' do
        post = create(:post)
        expect { expect(posts_seeder.find_or_create).to eq([post]) }.not_to change { Thredded::Post.count }
      end

      it 'can make dates' do
        expect(posts_seeder.range_of_dates_in_order).to have_attributes(length: 1)
        now = 1.hour.ago
        dates = posts_seeder.range_of_dates_in_order(up_to: now, count: 200)
        expect(dates.last).to eq(now)
        expect(dates).to all(be <= now)
      end
    end
  end
end
