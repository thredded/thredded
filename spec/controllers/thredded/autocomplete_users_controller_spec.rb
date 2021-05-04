# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe AutocompleteUsersController do
    routes { Thredded::Engine.routes }

    let(:current_user) { create(:user, name: 'Ganymede') }

    before do
      allow(controller).to receive_messages(thredded_current_user: current_user)
      allow(Thredded).to receive(:autocomplete_min_length).and_return(2)
    end

    describe 'index' do
      let!(:users) { %w[Gilda Gary Gazza gandalf].map { |n| create(:user, :approved, name: n) } }
      let!(:user_pending_moderation) { create(:user, :pending_moderation, name: 'Gargamel') }
      let!(:user_blocked) { create(:user, :blocked, name: 'Gall') }

      let(:json_response_results) { JSON.parse(response.body)['data'] }

      it 'under minimum length returns nothing' do
        get :index, format: 'json', params: { q: 'g' }
        expect(json_response_results).to eq([])
      end

      it "'doesn't include current_user'" do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['attributes']['name'] }).to include('gandalf', 'Gary', 'Gazza')
        expect(json_response_results.map { |r| r['attributes']['name'] }).not_to include('Ganymede')
      end

      it "'doesn't include pending users'" do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['attributes']['name'] }).to include('gandalf', 'Gary', 'Gazza')
        expect(json_response_results.map { |r| r['attributes']['name'] }).not_to include('Gargamel')
      end

      it "'doesn't include blocked users'" do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['attributes']['name'] }).to include('gandalf', 'Gary', 'Gazza')
        expect(json_response_results.map { |r| r['attributes']['name'] }).not_to include('Gall')
      end

      it 'returns records' do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.first['attributes'].keys).to include('admin', 'email', 'name', 'created_at', 'updated_at')
      end

      it 'returns results, ordered' do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['attributes']['name'] }).to eq(%w[gandalf Gary Gazza])
      end
    end
  end
end
