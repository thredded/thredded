# frozen_string_literal: true

module Thredded
  class NewsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy]

    after_action :verify_authorized, except: %i[index show]

    def index
      @news = News.all
      render json: NewsSerializer.new(@news, include: %i[user]).serializable_hash.to_json, status: 200
    end

    def show
      render json: NewsSerializer.new(news, include: %i[user]).serializable_hash.to_json, status: 200
    end

    def create
      @news = News.new(news_params)
      authorize_creating @news

      if @news.save
        render json: NewsSerializer.new(@news, include: %i[user]).serializable_hash.to_json, status: 201
      else
        render json: { errors: @news.errors }, status: 422
      end
    end

    def update
      authorize news, :update?
      if news.update(news_params)
        render json: NewsSerializer.new(news, include: %i[user]).serializable_hash.to_json, status: 200
      else
        render json: { errors: news.errors }, status: 422
      end
    end

    def destroy
      authorize news, :destroy?
      news.destroy!
      head 204
    end

    private

    def news_params
      params
        .require(:news)
        .permit(:title, :description, :short_description, :url, :topic_id, :news_banner)
      .merge(
           user: thredded_current_user
      )
    end

    def news
      @news ||= Thredded::News.find!(params[:id])
    end
  end
end
