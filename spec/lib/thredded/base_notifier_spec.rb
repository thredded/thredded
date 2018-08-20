# frozen_string_literal: true

require 'spec_helper'

describe Thredded::BaseNotifier do
  describe 'validate_notifier' do
    subject(:validate_notifier) { described_class.validate_notifier(candidate_notifier_class.new) }

    let(:candidate_notifier_class) do
      Class.new.tap do |klass|
        candidate_notifier_methods.each_pair do |m, v|
          klass.send(:define_method, m) do
            v
          end
        end
      end
    end
    let(:candidate_notifier_methods) do
      { key: 'candidate', human_name: 'Candidate', new_post: 'done',
        new_private_post: 'done' }
    end

    it 'candidate works' do
      expect { validate_notifier }.not_to raise_error
    end
    describe 'key' do
      context 'not responding' do
        let(:candidate_notifier_methods) { super().tap { |h| h.delete(:key) } }

        it 'raises error' do
          expect { validate_notifier }.to raise_error(/key/)
        end
      end

      context 'not method name' do
        let(:candidate_notifier_methods) { super().merge(key: 'some thing with Others') }

        it 'raises error' do
          expect { validate_notifier }.to raise_error(/key/)
        end
      end
    end

    describe 'human_name' do
      context 'not responding' do
        let(:candidate_notifier_methods) { super().tap { |h| h.delete(:human_name) } }

        it 'raises error' do
          expect { validate_notifier }.to raise_error(/human_name/)
        end
      end
    end

    describe 'new_post' do
      context 'not responding' do
        let(:candidate_notifier_methods) { super().tap { |h| h.delete(:new_post) } }

        it 'raises error' do
          expect { validate_notifier }.to raise_error(/new_post/)
        end
      end
    end

    describe 'new_private_post' do
      context 'not responding' do
        let(:candidate_notifier_methods) { super().tap { |h| h.delete(:new_private_post) } }

        it 'raises error' do
          expect { validate_notifier }.to raise_error(/new_private_post/)
        end
      end
    end
  end
end
