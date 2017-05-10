# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PostPolicy do
    subject { described_class }
    let(:user) { Thredded.user_class.new }

    permissions :update? do
      it 'granted access to the user who started the topic' do
        expect(subject).to permit(user, Post.new(user: user))
      end
    end

    permissions :create? do
      it 'granted if you are allowed to create a topic' do
        expect(MessageboardPolicy).to receive(:new).and_return(double('post?' => true))
        expect(subject).to permit(user, build_stubbed(:post))
      end

      it 'denied if you are not allowed to create a topic' do
        expect(MessageboardPolicy).to receive(:new).and_return(double('post?' => false))
        expect(subject).to_not permit(user, build_stubbed(:post))
      end

      it 'denied if the topic is locked' do
        allow(MessageboardPolicy).to receive(:new).and_return(double('post?' => true))
        expect(subject).to_not permit(user, Post.new(postable: Topic.new(locked: true)))
      end
    end
  end
end
