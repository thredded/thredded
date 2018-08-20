# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe TopicPolicy do
    subject(:policy) { described_class }

    let(:user) { Thredded.user_class.new }

    permissions :create? do
      it 'granted if MessageboardPolicy#post? is true' do
        expect(MessageboardPolicy).to receive(:new).and_return(instance_double(MessageboardPolicy, 'post?' => true))
        expect(policy).to permit(user, build_stubbed(:post))
      end

      it 'denied if MessageboardPolicy#post? is false' do
        expect(MessageboardPolicy).to receive(:new).and_return(instance_double(MessageboardPolicy, 'post?' => false))
        expect(policy).not_to permit(user, build_stubbed(:post))
      end
    end
  end
end
