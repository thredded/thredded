require 'thredded/search_sql_builder'

module Thredded
  class Topic < ActiveRecord::Base
    include TopicCommon
    extend FriendlyId
    friendly_id :title, use: [:history, :scoped], scope: :messageboard

    has_many :posts,
      -> { includes :attachments },
      as: :postable,
      dependent: :destroy
    has_many :topic_categories, dependent: :destroy
    has_many :categories, through: :topic_categories
    has_many :user_topic_reads, dependent: :destroy
    has_one :user_detail, through: :user, source: :thredded_user_detail

    after_create :increment_topics_count

    def self.stuck
      where(sticky: true)
    end

    def self.unstuck
      where(sticky: false)
    end

    def self.order_by_updated_time
      order('thredded_topics.updated_at DESC')
    end

    def self.order_by_stuck_and_updated_time
      order('thredded_topics.sticky DESC, thredded_topics.updated_at DESC')
    end

    def self.search(query, messageboard)
      sql_builder = SearchSqlBuilder.new(query, messageboard)
      sql = sql_builder.build
      sql_params = [sql].concat(sql_builder.binds)
      results = find_by_sql(sql_params)

      fail(Thredded::Errors::EmptySearchResults, query) if results.empty?

      results
    end

    def self.find_by_slug_with_user_topic_reads!(slug)
      includes(:user_topic_reads).friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::TopicNotFound
    end

    def decorate
      TopicDecorator.new(self)
    end

    def public?
      true
    end

    def private?
      false
    end

    def self.inherited(child)
      child.instance_eval do
        def model_name
          Topic.model_name
        end
      end

      super
    end

    def self.select_options
      subclasses.map(&:to_s).sort
    end

    def self.recent
      limit(10)
    end

    def updating?
      id.present?
    end

    def categories_to_sentence
      categories.map(&:name).to_sentence if categories.any?
    end

    def users_to_sentence
      []
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    private

    def increment_topics_count
      user_detail.increment!(:topics_count) if user_detail
    end
  end
end
