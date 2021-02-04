# frozen_string_literal: true

RelationshipSchema = Dry::Schema.Params do
  required(:data).schema do
    required(:id).filled(:string)
    required(:type).filled(:string)
  end
end
