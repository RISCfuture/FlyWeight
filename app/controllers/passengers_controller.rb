# RESTful controller for creating and deleting passengers of a flight. Only
# authenticated users can remove passengers; all other actions are available to
# unauthenticated sessions.

class PassengersController < ApplicationController
  before_action :find_flight
  before_action :find_passenger, only: %i[destroy show]
  before_action :authenticate_pilot!, except: %i[create show]

  # Displays a page thanking a passenger for sharing their weight. This page is
  # shown after an unauthenticated session finishes a passenger-create
  # submission.
  #
  # For authenticated sessions, this action redirects to the flight's edit page.
  #
  # Routes
  # ------
  #
  # * `GET /flights/:flight_id/passengers/:id`
  #
  # Query Parameters
  # ----------------
  #
  # |             |                        |
  # |:------------|:-----------------------|
  # | `flight_id` | The UUID of a Flight.  |
  # | `id`        | The ID of a Passenger. |

  def show
    return redirect_to(@flight) if pilot_signed_in?

    respond_to do |format|
      format.html
    end
  end

  # Creates a passenger from the given parameters. If the passenger name matches
  # one that's already in the flight, that passenger is updated.
  #
  # Routes
  # ------
  #
  # * `POST /flights/:flight_id/passengers`
  #
  # Query Parameters
  # ----------------
  #
  # |             |                       |
  # |:------------|:----------------------|
  # | `flight_id` | The UUID of a Flight. |
  #
  # Body Parameters
  # ---------------
  #
  # |             |                                       |
  # |:------------|:--------------------------------------|
  # | `passenger` | The attributes for the new Passenger. |

  def create
    @passenger = @flight.passengers.find_or_initialize_by(name: passenger_params[:name])
    @passenger.attributes = passenger_params
    @passenger.save
    respond_to_save
  end

  # Removes a passenger from a flight (deleting the Passenger record).
  #
  # Routes
  # ------
  #
  # * `DELETE /flights/:flight_id/passengers/:id`
  #
  # Query Parameters
  # ----------------
  #
  # |             |                        |
  # |:------------|:-----------------------|
  # | `flight_id` | The UUID of a Flight.  |
  # | `id`        | The ID of a Passenger. |

  def destroy
    @passenger.destroy
    respond_to do |format|
      format.html { redirect_to @flight }
      format.turbo_stream { redirect_to @flight, status: :see_other }
    end
  end

  private

  def find_flight
    @flight = if pilot_signed_in?
                current_pilot.flights.find_by_uuid!(params[:flight_id])
              else
                Flight.find_by_uuid!(params[:flight_id])
              end
  end

  def find_passenger
    @passenger = @flight.passengers.find(params[:id])
  end

  def passenger_params
    params.require(:passenger).permit :name, :weight, :bags_weight
  end

  def respond_to_save
    respond_to do |format|
      format.turbo_stream do
        if @passenger.valid?
          if pilot_signed_in?
            redirect_to @flight, status: :see_other
          else
            redirect_to flight_passenger_url(@flight, @passenger), status: :see_other
          end
        else
          render status: :unprocessable_entity
        end
      end
      format.html do
        if @flight.valid?
          if pilot_signed_in?
            redirect_to @flight
          else
            redirect_to flight_passenger_url(@flight, @passenger)
          end
        else
          render(pilot_signed_in? ? 'flights/edit' : 'flights/show')
        end
      end
    end
  end
end
