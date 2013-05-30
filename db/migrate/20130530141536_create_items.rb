class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :sellable, index: true, :polymorphic => true
      t.string :name
      t.float :fixed_price

      t.timestamps
    end
  end
end
