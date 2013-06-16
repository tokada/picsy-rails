class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.belongs_to :market, index: true

      t.references :buyable, index: true, :polymorphic => true
      t.references :sellable, index: true, :polymorphic => true
      t.float :amount

      t.timestamps
    end
  end
end
