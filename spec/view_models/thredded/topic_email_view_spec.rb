# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe TopicEmailView do
    let(:messageboard) { build_stubbed(:messageboard, name: 'hello') }
    let(:topic) { build_stubbed(:topic, messageboard: messageboard) }
    let(:decorated_topic) { TopicEmailView.new(topic) }

    describe '.smtp_api_tag' do
      it 'returns a string that looks like JSON (for sendgrid)' do
        expect(decorated_topic.smtp_api_tag('some_tag'))
          .to eq '{"category": ["thredded_hello","some_tag"]}'
      end
    end

    describe '.subject' do
      it 'returns a subject for this topic' do
        expect(decorated_topic.subject)
          .to eq("#{Thredded.email_outgoing_prefix} #{topic.title}")
      end
    end

    describe '.no_reply' do
      it 'returns the standard email-from address' do
        expect(decorated_topic.no_reply)
          .to eq(Thredded.email_from)
      end
    end

    describe '.reply_to' do
      it 'returns the reply-to address for the app' do
        expect(decorated_topic.reply_to)
          .to eq("#{topic.hash_id}@#{Thredded.email_incoming_host}")
      end
    end
  end
end
