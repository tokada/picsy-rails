json.array!(@markets) do |market|
  json.extract! market, :name, :people_count
  json.url market_url(market, format: :json)
end