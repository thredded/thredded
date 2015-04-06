require 'spec_helper'

module Thredded
  describe TopicsController do
    before(:each) do
      @routes = Thredded::Engine.routes
    end

    before do
      user          = create(:user)
      @messageboard = create(:messageboard)
      @topic        = create(:topic, messageboard: @messageboard, title: 'hi')
      @post         = create(:post, postable: @topic, content: 'hi')
      allow(controller).to receive_messages(
        topics:        [@topic],
        sticky_topics: [],
        cannot?:       false,
        current_user:  user,
        messageboard:  @messageboard
      )
    end

    it 'renders GET index' do
      get :index, messageboard_id: @messageboard.id

      expect(response).to be_successful
      expect(response).to render_template('index')
    end

    describe 'GET search' do
      it 'renders search' do
        allow(Topic).to receive_messages(search: [@topic])
        get :search, messageboard_id: @messageboard.id, q: 'hi'

        expect(response).to be_successful
        expect(response).to render_template('search')
      end

      it 'is successful with spaces around search term(s)' do
        allow(Topic).to receive_messages(search: [@topic])
        get :search, messageboard_id: @messageboard.id, q: '  hi  '

        expect(response).to be_successful
      end

      it 'returns nothing when query is empty' do
        allow(Topic).to receive(:search) { fail Thredded::Errors::EmptySearchResults, 'hi' }
        get :search, messageboard_id: @messageboard.id, q: ''

        expect(flash[:alert]).to eq "There are no results for your search - 'hi'"
      end
    end
  end
end
