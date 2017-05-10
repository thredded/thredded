# frozen_string_literal: true
class UpgradeThreddedV011ToV012 < (Thredded.rails_gte_51? ? ActiveRecord::Migration[5.1] : ActiveRecord::Migration)
  def up
    FriendlyId::Slug.transaction do
      FriendlyId::Slug.where(sluggable_type: 'Thredded::Topic').where(
        slug: FriendlyId::Slug.group(:slug).having('count(id) > 1').select(:slug)
      ).group_by(&:slug).each_value do |slugs|
        slugs.from(1).each(&:delete)
      end
      FriendlyId::Slug.where(sluggable_type: 'Thredded::Topic')
        .update_all(scope: nil)
    end
    Thredded::Topic.all.find_each do |topic|
      # re-generate the slug
      topic.title_will_change!
      topic.save!
    end
    remove_index :thredded_topics, name: :index_thredded_topics_on_messageboard_id_and_slug
    add_index :thredded_topics, [:slug], name: :index_thredded_topics_on_slug, unique: true
  end

  def down
    fail ActiveRecord::MigrationError::IrreversibleMigration
  end
end
