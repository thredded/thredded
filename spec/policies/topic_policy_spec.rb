# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe TopicPolicy do
    subject { described_class }
    let(:user) { Thredded.user_class.new }

    permissions :create? do
      it 'granted if MessageboardPolicy#post? is true' do
        expect(MessageboardPolicy).to receive(:new).and_return(double('post?' => true))
        expect(subject).to permit(user, build_stubbed(:post))
      end

      it 'denied if MessageboardPolicy#post? is false' do
        expect(MessageboardPolicy).to receive(:new).and_return(double('post?' => false))
        expect(subject).to_not permit(user, build_stubbed(:post))
      end
    end
  end
end
