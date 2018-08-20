# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PostPolicy do
    subject(:policy) { described_class }

    let(:user) { Thredded.user_class.new }

    permissions :update? do
      it 'granted access to the user who started the topic' do
        expect(policy).to permit(user, Post.new(user: user))
      end
    end

    permissions :create? do
      it 'granted if you are allowed to create a topic' do
        expect(user).to receive(:thredded_can_write_messageboards)
          .and_return(instance_double(ActiveRecord::Relation, 'include?' => true))
        expect(policy).to permit(user, build_stubbed(:post))
      end

      it 'denied if you are not allowed to create a topic' do
        expect(user).to receive(:thredded_can_write_messageboards)
          .and_return(instance_double(ActiveRecord::Relation, 'include?' => false))
        expect(policy).not_to permit(user, build_stubbed(:post))
      end

      it 'denied if the topic is locked' do
        allow(MessageboardPolicy).to receive(:new).and_return(instance_double(MessageboardPolicy, 'post?' => true))
        expect(policy).not_to permit(user, Post.new(postable: Topic.new(locked: true)))
      end
    end
  end
end
