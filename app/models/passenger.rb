# frozen_string_literal: true

# A Passenger record stores the name and weight of a passenger who will
# participate in a {Flight}. It is also used to record baggage not associated
# with a passenger; in this case, `weight` is zero.
#
# Passenger updates are broadcast to authenticated listeners using Turbo
# Streams.
#
# Associations
# ------------
#
# |          |                                              |
# |:---------|:---------------------------------------------|
# | `flight` | The Flight this passenger will be a part of. |
#
# Properties
# ----------
#
# |                           |                                                                                                       |
# |:--------------------------|:------------------------------------------------------------------------------------------------------|
# | `name`                    | The passenger's name.                                                                                 |
# | `weight`                  | The passenger's weight (including clothes), in pounds. For baggage, this is zero.                     |
# | `bags_weight`             | The weight of any bags the passenger is bringing, in pounds. For baggage, this is the baggage weight. |
# | `covid19_vaccine`         | `true` if the passenger has an up-to-date COVID 19 vaccination.                                       |
# | `covid19_test_negative`   | `true` if the passenger has had a recent negative COVID 19 test.                                      |
# | `covid19_vaccine_booster` | `true` if the passenger has had a COVID 19 booster shot.                                              |
#
# @todo When a new passenger is created and the passenger list HTML is pushed
#   out to WebSockets via Turbo Stream, the delete button has an invalid form
#   authenticity token, and the passenger therefore can't be deleted.

class Passenger < ApplicationRecord
  include Turbo::Broadcastable
  include Turbo::Streams::ActionHelper

  belongs_to :flight

  validates :name,
            presence: true,
            length:   {maximum: 100}
  validates :weight,
            presence:     true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than: 2000}
  validates :bags_weight,
            presence:     true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than: 2000}

  validate :total_weight_greater_than_zero

  broadcasts_to ->(pax) { [pax.flight, :passengers] }
  broadcasts

  scope :baggage, -> { where arel_table[:weight].eq(0).and(arel_table[:bags_weight].gt(0)) }
  scope :passengers, -> { where arel_table[:weight].gt(0) }

  # need custom overrides for broadcasts_to so we can update total-weight frame as well

  # @private
  def broadcast_action_later_to(*streamables, action: :append, target: broadcast_target_default, **)
    content = turbo_stream_action_tag(action, target:, template: stream_content) +
      turbo_stream_action_tag(:replace, target: "total-weight", template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content:)
  end

  # @private
  def broadcast_replace_later_to(*streamables, **)
    content = turbo_stream_action_tag(:replace, target: self, template: stream_content) +
      turbo_stream_action_tag(:replace, target: "total-weight", template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content:)
  end

  # @private
  def broadcast_remove_to(*streamables)
    content = turbo_stream_action_tag(:remove, target: self) +
      turbo_stream_action_tag(:replace, target: "total-weight", template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content:)
  end

  def baggage?
    weight.zero? && bags_weight.positive?
  end

  def passenger?
    weight.positive?
  end

  def total_weight
    weight + bags_weight
  end

  private

  def stream_content
    ApplicationController.render partial: to_partial_path, locals: {model_name.singular.to_sym => self}
  end

  def total_weight_content
    ApplicationController.render partial: "flights/total_weight", locals: {flight:}
  end

  def total_weight_greater_than_zero
    return if total_weight.positive?

    errors.add :weight, :greater_than_or_equal_to, count: 0
    errors.add :bags_weight, :greater_than_or_equal_to, count: 0
  end
end
