class CreatePropagations < ActiveRecord::Migration
  def change
    create_table :propagations do |t|
      t.belongs_to :market, index: true
      t.belongs_to :trade, index: true
      t.references :evaluatable, index: true, :polymorphic => true
      t.float :amount
      t.string :category

      t.timestamps
    end
  end
end
