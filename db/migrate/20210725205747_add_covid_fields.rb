# frozen_string_literal: true

class AddCovidFields < ActiveRecord::Migration[6.1]
  def change
    change_table :passengers do |t|
      t.boolean :covid19_vaccine, :covid19_test_negative, null: false, default: false
    end
  end
end
