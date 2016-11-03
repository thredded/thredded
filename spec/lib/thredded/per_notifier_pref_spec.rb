# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PerNotifierPref do
    subject { PerNotifierPref.new }
    describe 'notifier keys' do
      context 'with two notifiers', thredded_reset: ['@@notifiers'] do
        before do
          Thredded.notifiers = [Thredded::EmailNotifier.new, MockNotifier.new]
        end
        it 'can read via their keys' do
          expect(subject).to respond_to(:email, :mock)
        end
        it 'can set via their keys' do
          expect do
            subject.email = false
          end.to change { subject.email }
          expect do
            subject.mock = false
          end.to change { subject.mock }
        end
      end
      context 'with default (email) notifier' do
        it 'can read via key' do
          expect(subject).to respond_to(:email)
        end
        it 'can set via key' do
          expect do
            subject.email = false
          end.to change { subject.email }
        end
        it "double check previous specs haven't leaked over" do
          expect(subject).to_not respond_to(:mock, :mock=)
        end
      end
    end

    describe 'new' do
      it 'should work with params' do
        instance = PerNotifierPref.new('email' => '1', 'other' => '0')
        expect(instance['email']).to be_truthy
        expect(instance['other']).to be_falsey
      end
    end
    describe 'serialization' do
      subject { PerNotifierPref }
      describe '.dump' do
        it 'dumps an empty into nil' do
          expect(subject.dump(PerNotifierPref.new)).to be_blank
        end

        it 'dumps instances with a falsey value' do
          instance = PerNotifierPref.new
          instance['somekey'] = false
          expect(subject.dump(instance)).to eq('somekey:false')
        end
        it 'dumps instances with a truthy value' do
          instance = PerNotifierPref.new
          instance['somekey'] = true
          expect(subject.dump(instance)).to eq('somekey:true')
        end

        it 'dumps instances with multiple values' do
          instance = PerNotifierPref.new
          instance['key1'] = false
          instance['otherkey'] = true
          instance['key2'] = false
          expect(subject.dump(instance)).to eq('key1:false,otherkey:true,key2:false')
        end
      end

      describe '.load' do
        it 'loads an nil as nil (so it works correctly as a serializer with default values)' do
          instance = subject.load(nil)
          expect(instance).to be_nil
        end

        it 'loads an blank as an empty instance' do
          instance = subject.load('')
          expect(instance).to be_a(PerNotifierPref)
          expect(instance['any_old_key']).to be_truthy
        end

        it 'loads a key as a false value' do
          instance = subject.load('key1:false')
          expect(instance).to be_a(PerNotifierPref)
          expect(instance['any_old_key']).to be_truthy
          expect(instance['key1']).to be_falsey
        end

        it 'loads multiple keys correctly ' do
          instance = subject.load('somekey:true,key1:false,key2:false')
          expect(instance).to be_a(PerNotifierPref)
          expect(instance['somekey']).to be_truthy
          expect(instance['key1']).to be_falsey
          expect(instance['key2']).to be_falsey
        end
      end

      describe 'roundtrip' do
        def roundtrip_from_value(value)
          PerNotifierPref.dump(PerNotifierPref.load(value))
        end

        it 'should roundtrip empty string as blank' do
          expect(roundtrip_from_value('')).to be_blank
        end
      end
    end
  end
end
