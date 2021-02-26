# @abstract
#
# Abstract superclass for FlyWeight controllers. All responses are HTML or
# HTML-over-the-wire. Typical responses:
#
# ## Record saved
#
# If a record is saved successfully, the user will be redirected to a relevant
# next page. For HTML requests, this will be a 302 Found response. For Turbo
# Streams requests, this will be a 303 See Other response.
#
# ## Record not found
#
# The response will be a 404 Not Found.
#
# ## Unauthorized (not logged in)
#
# The response will be a redirect to the home page.
#
# ## Record failed validation
#
# The response will be a 422 Unprocessable Entity. The response body will be
# a re-rendered form including validation errors.

class ApplicationController < ActionController::Base
  include ActionController::MimeResponds

  rescue_from(ActiveRecord::RecordNotFound, ActionController::RoutingError) do |_error|
    respond_to do |format|
      format.html { render file: 'public/404.html', status: :not_found, layout: false }
    end
  end

  rescue_from(ActionController::BadRequest) do
    respond_to do |format|
      format.html { render file: 'public/400.html', status: :bad_request, layout: false }
    end
  end

  rescue_from(ActionController::MethodNotAllowed) do
    respond_to do |format|
      format.html { render file: 'public/405.html', status: :method_not_allowed, layout: false }
    end
  end

  rescue_from(ActionController::UnknownFormat) do
    respond_to do |format|
      format.html { render file: 'public/406.html', status: :not_acceptable, layout: false }
    end
  end

  before_bugsnag_notify :add_user_info_to_bugsnag
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :html, :turbo_stream

  private

  def add_user_info_to_bugsnag(report)
    report.user = {
        id: current_user.id
    } if squadron_signed_in?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[name email]
    devise_parameter_sanitizer.permit :account_update, keys: %i[name email]
  end

  def confirm_flight_ownership
    if @flight.pilot_id != current_pilot.id
      raise ActiveRecord::RecordNotFound.new(
        "Flight is not owned by you",
        Flight,
        :uuid,
        params[:id]
      )
    end

    return true
  end
end
