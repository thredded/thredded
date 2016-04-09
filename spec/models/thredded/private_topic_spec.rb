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
  end
end
