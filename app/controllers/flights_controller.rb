# RESTful controller for viewing and creating {Flight}s.
#
# Only the {#show} action is available to non-pilots.

class FlightsController < ApplicationController
  before_action :authenticate_pilot!, except: :show
  before_action :find_any_flight, only: :show
  before_action :find_my_flight, only: %i[update destroy]

  # Displays a list of the current pilot's flights.
  #
  # Routes
  # ------
  #
  # * `GET /flights`

  def index
    @flights   = current_pilot.flights.
        not_ancient.
        order(date: :asc, created_at: :asc).
        limit(50) #TODO pagination
    pax_counts = @flights.reorder('').joins(:passengers).group(:flight_id).count
    @flights   = @flights.to_a

    @flights.each do |flight|
      flight.passenger_count = pax_counts[flight.id] || 0
    end

    respond_to do |format|
      format.html
    end
  end

  # For authenticated sessions, displays a page where the passenger list for a
  # flight can be viewed, passengers can be added or removed, or the flight can
  # be edited.
  #
  # For unauthenticated sessions, displays a page where a passenger can add
  # their weight to a flight.
  #
  # Routes
  # ------
  #
  # * `GET /flights/:id`
  #
  # Query Parameters
  # ----------------
  #
  # |      |                           |
  # |:-----|:--------------------------|
  # | `id` | The UUID of the {Flight}. |

  def show
    @passenger = @flight.passengers.build
    respond_to do |format|
      format.html { render(my_flight? ? 'edit' : 'show') }
    end
  end

  # Displays a page where a pilot can create a new flight.
  #
  # Routes
  # ------
  #
  # * `GET /flights/new`

  def new
    @flight = Flight.new
    respond_to do |format|
      format.html
    end
  end

  # Creates a new flight from the given parameters. Redirects to the flights
  # list if successful; re-renders the form if validation fails.
  #
  # Routes
  # ------
  #
  # * `POST /flights`
  #
  # Body Parameters
  # ---------------
  #
  # |          |                                    |
  # |:---------|:-----------------------------------|
  # | `flight` | The attributes for the new Flight. |

  def create
    @flight = current_pilot.flights.create(flight_params)
    respond_to_save
  end

  # Updates a flight from the given parameters. Redirects to the flight page
  # if successful; re-renders the form if validation fails.
  #
  # Routes
  # ------
  #
  # * `PATCH /flights/:id`
  #
  # Query Parameters
  # ----------------
  #
  # |      |                           |
  # |:-----|:--------------------------|
  # | `id` | The UUID of the {Flight}. |
  #
  # Body Parameters
  # ---------------
  #
  # |          |                                    |
  # |:---------|:-----------------------------------|
  # | `flight` | The attributes for the new Flight. |

  def update
    @flight.update(flight_params)
    respond_to_save
  end

  # Removes a flight and its passengers.
  #
  # Routes
  # ------
  #
  # * `DELETE /flights/:id`
  #
  # Query Parameters
  # ----------------
  #
  # |      |                           |
  # |:-----|:--------------------------|
  # | `id` | The UUID of the {Flight}. |

  def destroy
    @flight.destroy
    respond_to do |format|
      format.html { redirect_to flights_url }
      format.turbo_stream { redirect_to flights_url, status: :see_other }
    end
  end

  private

  def find_any_flight
    @flight = Flight.find_by!(uuid: params[:id])
  end

  def find_my_flight
    @flight = current_pilot.flights.find_by!(uuid: params[:id])
  end

  def flight_params
    params.require(:flight).permit :description, :date
  end

  def respond_to_save
    respond_to do |format|
      format.turbo_stream do
        if @flight.valid?
          redirect_to @flight, status: :see_other
        else
          @passenger = @flight.passengers.build
          render status: :unprocessable_entity
        end
      end
      format.html do
        if @flight.valid?
          redirect_to @flight
        else
          @passenger = @flight.passengers.build
          render(@flight.persisted? ? 'flights/edit' : 'flights/new')
        end
      end
    end
  end
end
