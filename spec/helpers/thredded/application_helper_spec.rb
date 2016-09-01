# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe ApplicationHelper do
    include ApplicationHelper
    describe '#user_mention' do
      it 'can create user_mention without quotes' do
        expect(user_mention(build(:user, name: 'eric'))).to eq('@eric')
      end
      it 'can create user_mention with quotes when needed' do
        expect(user_mention(build(:user, name: 'eric the bee'))).to eq('@"eric the bee"')
      end

      it 'can uses correct name, even if to_s provides something different' do
        eric = build(:user, name: 'eric')
        allow(eric).to receive(:to_s).and_return('Eric the Half-a-bee')
        expect(user_mention(eric)).to eq('@eric')
      end
    end
  end
end
