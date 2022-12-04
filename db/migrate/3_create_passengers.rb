# frozen_string_literal: true

class CreatePassengers < ActiveRecord::Migration[6.1]
  def change
    create_table :passengers do |t|
      t.belongs_to :flight, foreign_key: {on_delete: :cascade}, null: false
      t.string :name, null: false, limit: 100
      t.integer :weight, null: false
      t.timestamps
    end
  end
end
