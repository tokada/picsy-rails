json.array!(@trades) do |trade|
  json.extract! trade, :buyable_id, :sellable_id, :item_id, :amount
  json.url trade_url(trade, format: :json)
end