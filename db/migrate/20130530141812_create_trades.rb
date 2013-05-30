class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.references :buyable, index: true, :polymorphic => true
      t.references :sellable, index: true, :polymorphic => true
      t.belongs_to :item, index: true
      t.float :amount

      t.timestamps
    end
  end
end
