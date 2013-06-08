class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ##Omniauthable
      t.integer :uid, :limit => 8 #bigint‚É‚·‚é
      t.string :name
      t.string :provider
      t.string :image
      t.string :password

      t.timestamps
    end
  end
end
