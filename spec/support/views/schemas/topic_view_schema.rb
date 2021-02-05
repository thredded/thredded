# frozen_string_literal: true

TopicViewSchema = Dry::Schema.JSON do
  required(:data).array(:hash) do
    required(:id).filled(:string)
    required(:type).filled(:string)
    required(:relationships).schema do
      required(:topic).schema(RelationshipSchema)
    end
  end
end
