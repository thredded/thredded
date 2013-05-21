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
      @post = create(:post, topic: @topic, content: 'hi')
      controller.stub(get_topics: [@topic])
      controller.stub(get_sticky_topics: [])
      controller.stub(cannot?: false)
      controller.stub(current_user: user)
      controller.stub(messageboard: @messageboard)
    end

    it 'renders GET index' do
      get :index, messageboard_id: @messageboard.id
      response.should be_success
      response.should render_template('index')
    end

    describe 'GET search' do
      it 'renders search' do
        controller.stub(get_search_results: [@topic])
        get :search, messageboard_id: @messageboard.id, q: 'hi'
        response.should be_success
        response.should render_template('search')
      end

      it 'is successful with spaces around search term(s)' do
        controller.stub(get_search_results: [@topic])
        get :search, messageboard_id: @messageboard.id, q: '  hi  '
        response.should be_success
      end

      it 'returns nothing when query is empty' do
        controller.stub(get_search_results: [])
        get :search, messageboard_id: @messageboard.id, q: ''
        flash[:error].should eq('No topics found for this search.')
      end
    end
  end
end
