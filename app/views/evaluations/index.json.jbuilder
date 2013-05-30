json.array!(@evaluations) do |evaluation|
  json.extract! evaluation, :buyable_id, :sellable_id, :amount
  json.url evaluation_url(evaluation, format: :json)
end