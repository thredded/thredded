# frozen_string_literal: true

module Thredded
  class CategoriesController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy]

    after_action :verify_authorized, except: %i[index show]

    def index
      @categories = Category.all.order_by_title
      render json: CategorySerializer.new(@categories).serializable_hash.to_json, status: 200
    end

    def show
      render json: CategorySerializer.new(category, include: [:topics]).serializable_hash.to_json, status: 200
    end

    def create
      @category = Category.new(category_params)
      authorize_creating @category

      if @category.save
        render json: CategorySerializer.new(@category).serializable_hash.to_json, status: 201
      else
        render json: { errors: @category.errors }, status: 422
      end
    end

    def update
      authorize category, :update?
      if category.update(category_params)
        render json: CategorySerializer.new(category).serializable_hash.to_json, status: 200
      else
        render json: { errors: category.errors }, status: 422
      end
    end

    def destroy
      authorize category, :destroy?
      category.destroy!
      head 204
    end

    private

    def category_params
      params
        .require(:category)
        .permit(:name, :description, :locked, :position, :category_icon, :is_active)
    end

    def category
      @category ||= Thredded::Category.find!(params[:id])
    end
  end
end
