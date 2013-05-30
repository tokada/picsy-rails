json.array!(@people) do |person|
  json.extract! person, :name, :state, :contribution, :purchase_power
  json.url person_url(person, format: :json)
end