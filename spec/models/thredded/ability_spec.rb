require 'spec_helper'
require 'cancan/matchers'

module Thredded
  describe Thredded::Ability do
    context 'for a private messageboard' do
      let(:messageboard) { create(:messageboard, :private) }

      it 'allows members to view it' do
        user = create(:user, :with_user_details)
        messageboard.add_member(user)
        ability = Thredded::Ability.new(user)
        expect(ability).to be_able_to(:read, messageboard)
      end

      it 'does not allow a non-members to view it' do
        user = create(:user, :with_user_details)
        ability = Thredded::Ability.new(user)
        expect(ability).not_to be_able_to(:read, messageboard)
      end

      it 'does not allow anonymous to view it' do
        user = Thredded::NullUser.new
        ability = Thredded::Ability.new(user)
        expect(ability).not_to be_able_to(:read, messageboard)
      end
    end

    context 'for a topic' do
      it 'allows a user to read it' do
        topic = build_stubbed(:topic)
        ability = Thredded::Ability.new(build_stubbed(:user))
        expect(ability).to be_able_to(:read, topic)
      end

      context 'in a messageboard with logged_in permissions' do
        before(:each) do
          @user = create(:user)
          @messageboard = create(:messageboard, :restricted_to_logged_in)
          @topic  = create(:topic, messageboard: @messageboard)
        end

        it 'is not readable by anonymous visitors' do
          @user = Thredded::NullUser.new
          ability = Thredded::Ability.new(@user)
          expect(ability.can?(:read, @topic)).to eq false
        end

        it 'is readable by a logged in user' do
          ability = Thredded::Ability.new(@user)
          expect(ability.can?(:read, @topic)).to eq true
        end
      end

      context 'in a private messageboard' do
        before do
          @messageboard = build_stubbed(:messageboard, security: 'private')
          @topic = build_stubbed(:topic, messageboard: @messageboard)
          @user = build_stubbed(:user)
        end

        it 'allows a member to create a topic' do
          allow(@messageboard).to receive_messages(member?: true)
          ability = Thredded::Ability.new(@user)
          expect(ability).to be_able_to(:create, @topic)
        end

        it 'allows a member to read a topic' do
          allow(@messageboard).to receive_messages(member?: true)
          ability = Thredded::Ability.new(@user)
          expect(ability).to be_able_to(:read, @topic)
        end

        it 'does not allow a non-member to read a topic' do
          allow(@messageboard).to receive_messages(member?: false)
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:read, @topic)
        end

        it 'does not allow a non-member to create a topic' do
          allow(@messageboard).to receive_messages(member?: false)
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:create, @topic)
        end

        it 'does not allow a logged in user to create a topic' do
          allow(@messageboard).to receive_messages(member?: false)
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:create, @topic)
        end

        it 'does not allow a logged in user to read a topic' do
          allow(@messageboard).to receive_messages(member?: false)
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:create, @topic)
        end

        it 'does not allow a logged in user to list topics' do
          allow(@messageboard).to receive_messages(member?: false)
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:index, @topic)
        end

        it 'does not allow anonymous to create a topic' do
          @user = User.new
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:create, @topic)
        end

        it 'does not allow anonymous to read a topic' do
          @user = User.new
          ability = Thredded::Ability.new(@user)
          expect(ability).not_to be_able_to(:read, @topic)
        end
      end
    end

    context 'for a private topic' do
      it 'allows an involved user to read it' do
        user = build_stubbed(:user)
        ability = Thredded::Ability.new(user)
        private_topic = build_stubbed(:private_topic, users: [user])
        expect(ability).to be_able_to(:read, private_topic)
      end

      it 'does not allow a random user to read it' do
        random_user = build_stubbed(:user, name: 'joe')
        user = build_stubbed(:user)
        ability = Thredded::Ability.new(random_user)
        private_topic = build_stubbed(:private_topic, users: [user])
        expect(ability).not_to be_able_to(:read, private_topic)
      end

      it 'does not allow an admin to read it' do
        user = build_stubbed(:user)
        admin = build_stubbed(:user)
        allow(admin).to receive_messages(admins?: true)
        ability = Thredded::Ability.new(admin)
        private_topic = build_stubbed(:private_topic, users: [user])

        expect(ability).not_to be_able_to(:manage, private_topic)
        expect(ability).not_to be_able_to(:read, private_topic)
      end
    end
  end
end
