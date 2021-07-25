class AddCovidFields < ActiveRecord::Migration[6.1]
  def change
    add_column :passengers, :covid19_vaccine, :boolean, null: false, default: false
    add_column :passengers, :covid19_test_negative, :boolean, null: false, default: false
  end
end
