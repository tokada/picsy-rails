class CreatePropagations < ActiveRecord::Migration
  def change
    create_table :propagations do |t|
      t.belongs_to :trade, index: true
      t.references :actor_from, index: true
      t.references :actor_to, index: true
      t.float :amount

      t.timestamps
    end
  end
end
