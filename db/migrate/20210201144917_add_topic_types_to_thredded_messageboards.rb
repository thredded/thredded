class AddTopicTypesToThreddedMessageboards < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_messageboards, :topic_types, :text, default: ["Thredded::TopicDefault"].to_yaml
  end
end
