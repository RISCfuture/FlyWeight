# A Passenger record stores the name and weight of a passenger who will
# participate in a {Flight}.
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
# |               |                                                              |
# |:--------------|:-------------------------------------------------------------|
# | `name`        | The passenger's name.                                        |
# | `weight`      | The passenger's weight (including clothes), in pounds.       |
# | `bags_weight` | The weight of any bags the passenger is bringing, in pounds. |
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
            numericality: {only_integer: true, greater_than: 0, less_than: 2000}
  validates :bags_weight,
            presence:     true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than: 2000}

  broadcasts_to ->(pax) { [pax.flight, :passengers] }
  broadcasts

  # need custom overrides for broadcasts_to so we can update total-weight frame as well

  # @private
  def broadcast_action_later_to(*streamables, action: :append, target: broadcast_target_default, **)
    content = turbo_stream_action_tag(action, target: target, template: stream_content) +
      turbo_stream_action_tag(:replace, target: 'total-weight', template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content: content)
  end

  # @private
  def broadcast_replace_later_to(*streamables, **)
    content = turbo_stream_action_tag(:replace, target: self, template: stream_content) +
      turbo_stream_action_tag(:replace, target: 'total-weight', template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content: content)
  end

  # @private
  def broadcast_remove_to(*streamables)
    content = turbo_stream_action_tag(:remove, target: self) +
      turbo_stream_action_tag(:replace, target: 'total-weight', template: total_weight_content)
    Turbo::StreamsChannel.broadcast_stream_to(*streamables, content: content)
  end

  private

  def stream_content
    ApplicationController.render partial: to_partial_path, locals: {model_name.singular.to_sym => self}
  end

  def total_weight_content
    ApplicationController.render partial: 'flights/total_weight', locals: {flight: flight}
  end
end
