class MoveTopicsIntoPrivateTopics < ActiveRecord::Migration
  def up
    delete_topic_categories_associated_with_private_topics
    ensure_topic_slugs_are_not_nil
    copy_private_topics_to_new_table
    delete_old_private_topics_from_thredded_topics
  end

  def ensure_topic_slugs_are_not_nil
    execute <<-SQL
      UPDATE thredded_topics
      SET slug=''
      WHERE slug IS NULL
    SQL
  end

  def delete_topic_categories_associated_with_private_topics
    execute <<-SQL
      DELETE FROM thredded_topic_categories
      WHERE topic_id IN (
        SELECT tids.id FROM (
          SELECT DISTINCT t.id
          FROM thredded_topics t
          INNER JOIN thredded_topic_categories cat
          ON cat.topic_id=t.id
          WHERE t.type='Thredded::PrivateTopic'
        ) AS tids
      )
    SQL
  end

  def copy_private_topics_to_new_table
    execute <<-SQL
      INSERT INTO thredded_private_topics
      SELECT
        id,
        user_id,
        last_user_id,
        title,
        slug,
        messageboard_id,
        posts_count,
        hash_id,
        created_at,
        updated_at
      FROM thredded_topics
      WHERE type = 'Thredded::PrivateTopic'
    SQL
  end

  def delete_old_private_topics_from_thredded_topics
    execute <<-SQL
      DELETE FROM thredded_topics WHERE thredded_topics.type = 'Thredded::PrivateTopic'
    SQL
  end
end
