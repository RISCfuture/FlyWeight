class AddCovidBoosterShot < ActiveRecord::Migration[6.1]
  def change
    add_column :passengers, :covid19_vaccine_booster, :boolean, null: false, default: false
  end
end
