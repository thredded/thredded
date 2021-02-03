class TopicValidator < ActiveModel::Validator
  def validate(record)
    unless record&.messageboard&.topic_types&.include?(record.type)
      record.errors.add :messageboard, "Das Messageboard ist nicht passend für dieses Topic."
    end
  end
end