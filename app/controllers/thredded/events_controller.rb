# frozen_string_literal: true

module Thredded
  class EventsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy]

    after_action :verify_authorized, except: %i[index show]

    def index
      @event = Event.order_by_event_date.page params[:page]

      render json: EventSerializer.new(@event, include: %i[user]).serializable_hash.to_json, status: 200
    end

    def show
      render json: EventSerializer.new(event, include: %i[user]).serializable_hash.to_json, status: 200
    end

    def create
      @event = Event.new(event_params)
      authorize_creating @event

      if @event.save
        render json: EventSerializer.new(@event, include: %i[user]).serializable_hash.to_json, status: 201
      else
        render json: { errors: @event.errors }, status: 422
      end
    end

    def update
      authorize event, :update?
      if event.update(event_params)
        render json: EventSerializer.new(event, include: %i[user]).serializable_hash.to_json, status: 200
      else
        render json: { errors: event.errors }, status: 422
      end
    end

    def destroy
      authorize event, :destroy?
      event.destroy!
      head 204
    end

    private

    def event_params
      params
          .require(:event)
          .permit(:title, :description, :short_description, :url, :topic_url, :host, :event_date, :end_of_submission_date)
          .merge(
              user: thredded_current_user
          )
    end

    def event
      @event ||= Thredded::Event.find!(params[:id])
    end

  end
end
