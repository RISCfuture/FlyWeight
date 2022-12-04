# frozen_string_literal: true

# Overrides the actions in `Devise::SessionsController` to include Turbo
# Streams support.

class SessionsController < Devise::SessionsController

  # Visits to the log-in page are redirected to the root URL.

  def new
    redirect_to root_url
  end

  # @private
  def create
    if (self.resource = warden.authenticate(auth_options))
      sign_in resource_name, resource
    else
      @pilot = resource_class.new(sign_in_params)
      @failure = true
    end

    respond_to do |format|
      format.turbo_stream do
        if resource&.persisted?
          redirect_to flights_url, status: :see_other
        else
          render status: :unprocessable_entity
        end
      end
      format.html do
        if resource&.persisted?
          redirect_to flights_url
        else
          render "home/index"
        end
      end
    end
  end
end
