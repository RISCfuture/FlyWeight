# frozen_string_literal: true

class AddBagsToPassengers < ActiveRecord::Migration[6.1]
  def change
    add_column :passengers, :bags_weight, :integer, null: false, default: 0
  end
end
