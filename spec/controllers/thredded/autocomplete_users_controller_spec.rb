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
      let!(:users) { %w[Gilda Gary Gazza gandalf].map { |n| create(:user, name: n) } }

      let(:json_response_results) { JSON.parse(response.body)['results'] }

      it 'under minimum length returns nothing' do
        get :index, format: 'json', params: { q: 'g' }
        expect(json_response_results).to eq([])
      end

      it "'doesn't include current_user'" do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['display_name'] }).to include('gandalf', 'Gary', 'Gazza')
        expect(json_response_results.map { |r| r['display_name'] }).not_to include('Ganymede')
      end

      it 'returns records' do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.first.keys).to include('avatar_url', 'display_name', 'id', 'name')
      end

      it 'returns results, ordered' do
        get :index, format: 'json', params: { q: 'ga' }
        expect(json_response_results.map { |r| r['display_name'] }).to eq(%w[gandalf Gary Gazza])
      end
    end
  end
end
