require 'spec_helper'

module Thredded
  describe EnsureRoleExists, '#run' do
    it 'creates a role if it does not exist' do
      user = create(:user)
      messageboard = create(:messageboard)

      EnsureRoleExists.new(user: user, messageboard: messageboard).run

      roles = Thredded::Role.all
      role = roles.first

      expect(roles.count).to eq 1
      expect(role.user).to eq user
      expect(role.messageboard).to eq messageboard
    end

    it 'will not create one if it already exists' do
      user = create(:user)
      messageboard = create(:messageboard)
      create(:role, user: user, messageboard: messageboard)

      EnsureRoleExists.new(user: user, messageboard: messageboard).run
      roles = Thredded::Role.all
      role = roles.first

      expect(roles.count).to eq 1
      expect(role.user).to eq user
      expect(role.messageboard).to eq messageboard
    end
  end
end
