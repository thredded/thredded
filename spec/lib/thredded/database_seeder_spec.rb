# frozen_string_literal: true
require 'spec_helper'

describe Thredded::DatabaseSeeder do
  before { allow_any_instance_of(Thredded::DatabaseSeeder).to receive(:log) }
  describe 'run (seed)' do
    subject do
      # we don't actually run run, because it causes weird knock-on effects to other tests
      # something to do with the callbacks I think
      Thredded::DatabaseSeeder.new.seed(users: 2, topics: 1, posts: (1..1))
    end
    it 'works' do
      subject
    end
    it 'creates' do
      expect { subject }
        .to change { User.count }.and change { Thredded::Topic.count }.and change { Thredded::Messageboard.count }
    end
  end

  describe Thredded::DatabaseSeeder::Users do
    let(:seed_database) { Thredded::DatabaseSeeder.new }
    subject { Thredded::DatabaseSeeder::Users.new(seed_database) }
    it 'can be created' do
      expect { subject.find_or_create }.to change { User.count }
    end
    it 'can be retrieved' do
      user = create(:user)
      expect { expect(subject.find_or_create).to eq([user]) }.not_to change { User.count }
    end
  end

  describe Thredded::DatabaseSeeder::Topics do
    let(:seed_database) { Thredded::DatabaseSeeder.new }
    subject { Thredded::DatabaseSeeder::Topics.new(seed_database) }
    it 'can be created' do
      expect { subject.find_or_create }.to change { Thredded::Topic.count }
    end
    it 'can be retrieved' do
      topic = create(:topic)
      expect { expect(subject.find_or_create).to eq([topic]) }.not_to change { Thredded::Topic.count }
    end
  end

  describe Thredded::DatabaseSeeder::Posts do
    let(:seed_database) { Thredded::DatabaseSeeder.new }
    subject { Thredded::DatabaseSeeder::Posts.new(seed_database) }
    it 'can be created' do
      expect { subject.find_or_create }.to change { Thredded::Post.count }
    end
    it 'can be retrieved' do
      post = create(:post)
      expect { expect(subject.find_or_create).to eq([post]) }.not_to change { Thredded::Post.count }
    end
    it 'can make dates' do
      expect(subject.range_of_dates_in_order).to have_attributes(length: 1)
      now = 1.hour.ago
      dates = subject.range_of_dates_in_order(up_to: now, count: 200)
      expect(dates.last).to eq(now)
      dates.each { |date| expect(date).to be <= now }
    end
  end
end
