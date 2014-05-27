require 'spec_helper'

module Thredded
  describe TopicsController do
    before(:each) do
      @routes = Thredded::Engine.routes
    end

    before do
      user = create(:user)
      @messageboard = create(:messageboard)
      @topic = create(:topic, messageboard: @messageboard, title: 'hi')
      @post = create(:post, postable: @topic, content: 'hi')
      controller.stub(topics: [@topic])
      controller.stub(sticky_topics: [])
      controller.stub(cannot?: false)
      controller.stub(current_user: user)
      controller.stub(messageboard: @messageboard)
    end

    it 'renders GET index' do
      get :index, messageboard_id: @messageboard.id

      expect(response).to be_successful
      expect(response).to render_template('index')
    end

    describe 'GET search' do
      it 'renders search' do
        Topic.stub(search: [@topic])
        get :search, messageboard_id: @messageboard.id, q: 'hi'

        expect(response).to be_successful
        expect(response).to render_template('search')
      end

      it 'is successful with spaces around search term(s)' do
        Topic.stub(search: [@topic])
        get :search, messageboard_id: @messageboard.id, q: '  hi  '

        expect(response).to be_successful
      end

      it 'returns nothing when query is empty' do
        Topic.stub(:search) { fail Thredded::Errors::EmptySearchResults, 'hi' }
        get :search, messageboard_id: @messageboard.id, q: ''

        expect(flash[:alert]).to eq "There are no results for your search - 'hi'"
      end
    end
  end
end
