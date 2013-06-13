class AddDescriptionToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :description, :string
  end
end
