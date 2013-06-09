class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
			t.references :user
      t.string :name
      t.integer :people_count

      t.timestamps
    end
  end
end
