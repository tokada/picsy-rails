class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
			t.references :user
      t.string :name
      t.integer :people_count

      t.string :system, :default => "PICSY"

      t.integer :evaluation_parameter
      t.integer :initial_self_evaluation
      t.integer :natural_recovery_rate
      t.integer :natural_recovery_interval_sec
      t.timestamp :last_natural_recovery_at

      t.timestamps
    end
  end
end
