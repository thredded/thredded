# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe TruthyHashSerializer do
    subject { TruthyHashSerializer }

    describe '#dump' do
      it 'dumps an empty into nil' do
        expect(subject.dump(Hash.new(true))).to be_blank
      end

      it 'dumps hashes with a falsey value' do
        hash = Hash.new(true)
        hash['somekey'] = false
        expect(subject.dump(hash)).to eq('somekey')
      end

      it 'dumps hashes with multiple falsey values' do
        hash = Hash.new(true)
        hash['key1'] = false
        hash['otherkey'] = true
        hash['key2'] = false
        expect(subject.dump(hash)).to eq('key1,key2')
      end
    end

    describe '#load' do
      it 'loads an nil as nil (so it works correctly as a serializer with default values)' do
        hash = subject.load(nil)
        expect(hash).to be_nil
      end

      it 'loads an blank as an empty hash' do
        hash = subject.load('')
        expect(hash).to be_a(Hash)
        expect(hash['somekey']).to be_truthy
      end

      it 'loads a key as a false value' do
        hash = subject.load('key1')
        expect(hash).to be_a(Hash)
        expect(hash['any-old-key']).to be_truthy
        expect(hash['key1']).to be_falsey
      end

      it 'loads a key as a false value' do
        hash = subject.load('key1,key2')
        expect(hash).to be_a(Hash)
        expect(hash['somekey']).to be_truthy
        expect(hash['key1']).to be_falsey
        expect(hash['key2']).to be_falsey
      end
    end

    describe 'roundtrip' do
      def roundtrip_from_value(value)
        TruthyHashSerializer.dump(TruthyHashSerializer.load(value))
      end

      it 'should roundtrip empty string as blank' do
        expect(roundtrip_from_value('')).to be_blank
      end
    end
  end
end
