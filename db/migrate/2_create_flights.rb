class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.belongs_to :pilot, foreign_key: {on_delete: :cascade}, null: false

      t.string :uuid, null: false, index: {unique: true}
      t.string :description, limit: 100
      t.date :date

      t.timestamps
    end
  end
end
