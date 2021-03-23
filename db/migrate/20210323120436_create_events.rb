class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :thredded_events do |t|
      t.string :title, null: false
      t.text :description, null: true
      t.text :short_description, null: true
      t.string :host, null: true
      t.string :url, null: true
      t.integer :topic_url, null: true
      t.datetime :event_date, null: false
      t.datetime :end_of_submission_date, null: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.references :user, type: user_id_type, index: false
      t.index [:user_id], name: :index_thredded_events_on_user_id
    end
  end
  def user_id_type
    Thredded.user_class.columns.find { |c| c.name == Thredded.user_class.primary_key }.sql_type
  end
end
