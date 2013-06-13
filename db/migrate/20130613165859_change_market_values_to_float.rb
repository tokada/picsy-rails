class ChangeMarketValuesToFloat < ActiveRecord::Migration
  def change
    change_column :markets, :initial_self_evaluation, :float, :default => 0.0
  end
end
