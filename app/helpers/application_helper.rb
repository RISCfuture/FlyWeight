# frozen_string_literal: true

# Methods in this module are available to all FlyWeight views.

module ApplicationHelper

  # @return [true, false] Whether the user is at the `/flights` page.

  def my_flights?
    controller_name == "flights" && action_name == "index"
  end

  # @return [true, false] Whether the user is at the `/flights/new` page.

  def add_flight?
    controller_name == "flights" && (action_name == "new" || action_name == "create")
  end
end
