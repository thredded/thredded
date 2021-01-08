TopicViewSchema = Dry::Schema.JSON do
  required(:data).array(:hash) do
      required(:id).filled(:string)
      required(:type).filled(:string)
      required(:attributes).schema do
        required(:topic).schema(TopicSchema)
        required(:follow).schema(FollowSchema)
        required(:read_state).schema(ReadStateSchema)
      end
    end
  end

