# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe ApplicationHelper do
    include ApplicationHelper
    describe '#user_mention' do
      it 'can create user_mention without quotes' do
        expect(user_mention(build(:user, name: 'eric'))).to eq('@eric')
      end
      it 'can create user_mention with quotes when need' do
        expect(user_mention(build(:user, name: 'eric the bee'))).to eq('@"eric the bee"')
      end
    end
  end
end
