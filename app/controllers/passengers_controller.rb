# RESTful controller for creating and deleting passengers of a flight. Only
# authenticated users can remove passengers; all other actions are available to
# unauthenticated sessions.

class PassengersController < ApplicationController
  before_action :authenticate_pilot!, except: %i[create show]
  before_action :find_any_flight, only: %i[create show]
  before_action :find_my_flight, except: %i[create show]
  before_action :find_passenger, only: %i[destroy show]

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
    return redirect_to(@flight) if my_flight?

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

  def find_any_flight
    @flight = Flight.find_by_uuid!(params[:flight_id])
  end

  def find_my_flight
    if pilot_signed_in?
      @flight = current_pilot.flights.find_by_uuid!(params[:flight_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def find_passenger
    @passenger = @flight.passengers.find(params[:id])
  end

  def passenger_params
    pax_params = params.require(:passenger)
                       .permit(:name, :weight, :bags_weight, :covid19_vaccine,
                               :covid19_test_negative)
    pax_params['bags_weight'] = '0' if pax_params['bags_weight'].blank?
    return pax_params
  end

  def respond_to_save
    respond_to do |format|
      format.turbo_stream do
        if @passenger.valid?
          redirect_to after_save_destination, status: :see_other
        else
          render status: :unprocessable_entity
        end
      end
      format.html do
        if @flight.valid?
          redirect_to after_save_destination
        else
          render validation_failure_template
        end
      end
    end
  end

  def validation_failure_template
    my_flight? ? 'flights/edit' : 'flights/show'
  end

  def after_save_destination
    my_flight? ? @flight : flight_passenger_url(@flight, @passenger)
  end
end
