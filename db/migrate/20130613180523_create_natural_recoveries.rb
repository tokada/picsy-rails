class CreateNaturalRecoveries < ActiveRecord::Migration
  def change
    create_table :natural_recoveries do |t|
      t.references :market, :null => false, index: true
      t.float :ratio, :null => false
      t.text :data

      t.timestamps
    end
  end
end
