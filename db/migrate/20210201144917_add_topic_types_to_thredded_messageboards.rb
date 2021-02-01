class AddTopicTypesToThreddedMessageboards < ActiveRecord::Migration[6.0]
  def change
    add_column :thredded_messageboards, :topic_types, :text, array: true, default: ["Thredded::TopicDefault"]
  end
end
