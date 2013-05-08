module Thredded
  class Topic < ActiveRecord::Base
    STATES = %w{pending approved}

    extend FriendlyId
    friendly_id :title, use: :scoped, scope: :messageboard
    paginates_per 50 if self.respond_to?(:paginates_per)

    has_many   :posts, include: :attachments
    has_many   :topic_categories
    has_many   :categories, through: :topic_categories

    belongs_to :last_user, class_name: Thredded.user_class,
      foreign_key: 'last_user_id'

    belongs_to :user, class_name: Thredded.user_class

    belongs_to :messageboard, counter_cache: true, touch: true

    validates_inclusion_of :state, in: STATES
    validates_presence_of :hash_id
    validates_presence_of :last_user_id
    validates_presence_of :messageboard_id
    validates_numericality_of :posts_count
    validates_uniqueness_of :hash_id

    attr_accessible :category_ids,
      :last_user,
      :locked,
      :messageboard,
      :posts_attributes,
      :sticky,
      :type,
      :title,
      :user_id,
      :usernames

    accepts_nested_attributes_for :posts, reject_if: :updating?
    accepts_nested_attributes_for :categories

    default_scope order('updated_at DESC')

    delegate :name, :name=, :email, :email=, to: :user, prefix: true

    before_validation do
      self.hash_id = SecureRandom.hex(10) if self.hash_id.nil?
    end

    def self.stuck
      where('sticky = true')
    end

    def self.unstuck
      where('sticky = false OR sticky IS NULL')
    end

    def self.on_page(page_num)
      page(page_num).per(30)
    end

    def self.for_messageboard(messageboard)
      where(messageboard_id: messageboard.id)
    end

    def self.order_by_updated
      order('updated_at DESC')
    end

    def self.full_text_search(query, messageboard)
      if query.empty?
        []
      else
        sql_builder = SearchSqlBuilder.new(query, messageboard)
        sql = sql_builder.build
        sql_params = [sql].concat(sql_builder.binds)
        find_by_sql sql_params
      end
    end

    def last_user
      super || NullUser.new
    end

    def public?
      true
    end

    def private?
      false
    end

    def pending?
      state == 'pending'
    end

    def css_class
      classes = []
      classes << 'locked' if locked
      classes << 'sticky' if sticky
      classes << 'private' if private?
      classes.empty? ?  '' : "class=\"#{classes.join(' ')}\"".html_safe
    end

    def users
      []
    end

    def users_to_sentence
      ''
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

    def updating?
      id.present?
    end

    def categories_to_sentence
      if categories
        categories.map(&:name).to_sentence
      end
    end
  end
end
