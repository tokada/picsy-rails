class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :state
      t.float :contribution
      t.float :purchase_power

      t.timestamps
    end
  end
end
