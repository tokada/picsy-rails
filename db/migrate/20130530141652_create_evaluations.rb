class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :buyable, index: true
      t.references :sellable, index: true
      t.float :amount

      t.timestamps
    end
  end
end
