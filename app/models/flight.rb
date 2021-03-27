# A Flight is created by a {Pilot} so that passengers can list their weights by
# adding {Passenger} records. Flights cannot be viewed or edited by passengers,
# and are only available to pilots for one week after their scheduled date (see
# the `not_ancient` scope).
#
# Flights are always referenced by a UUID, which is automatically generated when
# the flight is first created.
#
# Flight updates are broadcast to authenticated listeners using Turbo Streams.
#
# Associations
# ------------
#
# |              |                                                  |
# |:-------------|:-------------------------------------------------|
# | `pilot`      | The Pilot that created this flight.              |
# | `passengers` | The Passengers that will be part of this flight. |
#
# Properties
# ----------
#
# |               |                                                       |
# |:--------------|:------------------------------------------------------|
# | `uuid`        | The unique, unguessable identifier for the flight.    |
# | `date`        | The date this flight is scheduled to take place.      |
# | `description` | An optional description of the purpose of the flight. |
#
# @todo A pilot can keep moving the date of a flight forward to get perpetual
#   access to passengers' weights.

class Flight < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :pilot
  has_many :passengers, dependent: :delete_all

  validates :description,
            length:    {maximum: 100},
            allow_nil: true
  validates :date,
            timeliness: {type: :date},
            allow_nil:  true
  validates :uuid,
            presence:   true,
            uniqueness: true,
            strict:     true

  before_validation :set_uuid, on: :create

  broadcasts_to ->(flight) { [flight.pilot, :flights] }
  broadcasts

  scope :not_ancient, -> { where(arel_table[:date].gteq(1.week.ago)) }

  # @private
  def to_param() uuid end

  # @return [Integer] The number of passengers associated with this flight. This
  # value is loaded from the database automatically, but can also be pre-set
  # using `#passenger_count=` for bulk loads.

  def passenger_count
    @passenger_count ||= passengers.count
  end

  # @private
  attr_writer :passenger_count

  # @return [Integer] The sum of all passenger and baggage weights.

  def total_weight
    passengers.sum(:weight) + passengers.sum(:bags_weight)
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end
end
