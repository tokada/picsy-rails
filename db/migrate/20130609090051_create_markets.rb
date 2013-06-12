class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
			t.references :user
      t.string :name
      t.integer :people_count
      t.integer :trades_count

      t.string :system, :default => "PICSY"

      t.integer :evaluation_parameter
      t.integer :initial_self_evaluation

      t.float :natural_recovery_ratio
      t.integer :natural_recovery_interval_sec

      t.timestamp :last_natural_recovery_at
      t.timestamp :last_trade_at
      t.timestamps
    end
  end
end
