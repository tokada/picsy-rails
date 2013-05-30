json.array!(@items) do |item|
  json.extract! item, :sellable_id, :name, :fixed_price
  json.url item_url(item, format: :json)
end