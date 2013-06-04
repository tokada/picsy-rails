class CreatePropagations < ActiveRecord::Migration
  def change
    create_table :propagations do |t|
      t.belongs_to :trade, index: true
      t.references :evaluatable, index: true, :polymorphic => true
      t.float :amount

      t.timestamps
    end
  end
end
