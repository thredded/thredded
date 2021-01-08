TopicSchema = Dry::Schema.JSON do
  required(:data).schema do
    required(:id).filled(:string)
    required(:type).filled(:string)
    required(:attributes).schema do
      required(:id).filled(:integer)
      required(:user_id).filled(:integer)
      required(:last_user_id).filled(:integer)
      required(:title).filled(:string)
      required(:slug).filled(:string)
      required(:messageboard_id).filled(:integer)
      required(:posts_count).filled(:integer)
      required(:sticky).filled(:bool)
      required(:locked).filled(:bool)
      required(:hash_id).filled(:string)
      required(:moderation_state).filled(:string)
      required(:last_post_at).filled(:string)
      required(:created_at).filled(:string)
      required(:updated_at).filled(:string)
    end
    required(:relationships).schema do
      required(:messageboard).schema(RelationshipSchema)
      required(:user).schema(RelationshipSchema)
      required(:last_user).schema(RelationshipSchema)
    end
  end
end

