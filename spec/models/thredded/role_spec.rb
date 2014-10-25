require 'spec_helper'

module Thredded
  describe Role do
    describe '#for(messageboard)' do
      it 'filters down roles only for this messagebaord' do
        messageboard = create(:messageboard)
        user = create(:user)
        messageboard.add_member(user)

        expect(Thredded::Role.for(messageboard).map(&:user)).to include(user)
      end
    end

    describe '#as(role)' do
      it 'filters down roles only for this particular role' do
        messageboard = create(:messageboard)
        user = create(:user)
        messageboard.add_member(user, 'admin')

        expect(Thredded::Role.as('admin').map(&:user)).to include(user)
      end
    end

    describe '#for(messageboard).as(role)' do
      it 'filters down roles for this messageboard' do
        messageboard = create(:messageboard)
        user = create(:user)
        messageboard.add_member(user, 'admin')

        expect(Thredded::Role.for(messageboard).as('admin').map(&:user)).to include(user)
      end
    end
  end
end
