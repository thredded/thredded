require 'spec_helper'

module Thredded
  describe PrivateTopic do
    before(:each) do
      @user1 = create(:user, name: 'privateuser1')
      @user2 = create(:user, name: 'privateuser2')
      @private_topic = create(
        :private_topic,
        users: [@user1, @user2]
      )
    end

    it 'does not allow someone not involved to read the topic' do
      @user3 = create(:user)
      ability = Ability.new(@user3)

      expect(ability.can?(:read, @private_topic)).to eq false
    end

    it 'allows someone included in the topic to read it' do
      ability = Ability.new(@user2)

      expect(ability.can?(:read, @private_topic)).to eq true
    end

    describe '.add_user' do
      before(:each) do
        @joel  = create(:user, name: 'joel')
      end

      it 'should add a user by their username' do
        @private_topic.add_user('joel')
        expect(@private_topic.users).to include(@joel)
      end

      it 'should add a user with a User object' do
        @private_topic.add_user(@joel)
        expect(@private_topic.users).to include(@joel)
      end
    end

    describe '.users_to_sentence' do
      it 'should list out the users in a topic in a human readable format' do
        expect(@private_topic.users_to_sentence).to eq 'Privateuser1 and Privateuser2'
      end
    end
  end
end
