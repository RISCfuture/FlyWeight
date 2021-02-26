class DeviseCreatePilots < ActiveRecord::Migration[6.1]
  def change
    create_table :pilots do |t|
      t.string :name, null: false, limit: 100

      ## Database authenticatable
      t.string :email, null: false
      t.string :encrypted_password, null: false

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :pilots, :email, unique: true
    add_index :pilots, :reset_password_token, unique: true
  end
end
