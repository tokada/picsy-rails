json.array!(@propagations) do |propagation|
  json.extract! propagation, :trade_id, :actor_from_id, :actor_to_id, :amount
  json.url propagation_url(propagation, format: :json)
end