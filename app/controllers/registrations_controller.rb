# Overrides the actions in `Devise::RegistrationsController` to include Turbo
# Streams support.

class RegistrationsController < Devise::RegistrationsController

  # Visits to the sign-up page are redirected to the root URL.

  def new
    redirect_to root_url
  end

  # @private
  def create
    build_resource sign_up_params
    resource.save

    if resource.persisted?
      sign_up resource_name, resource
    else
      clean_up_passwords resource
      set_minimum_password_length
    end

    respond_to_save(resource.persisted?)
  end

  # @private
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = update_resource(resource, account_update_params)

    if resource_updated
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
    else
      clean_up_passwords resource
      set_minimum_password_length
    end

    respond_to_save(resource_updated)
  end

  private

  def respond_to_save(valid)
    respond_to do |format|
      format.turbo_stream do
        if valid
          redirect_to flights_url, status: :see_other
        else
          render status: :unprocessable_entity
        end
      end
      format.html do
        if valid
          redirect_to flights_url
        else
          render 'home/index'
        end
      end
    end
  end
end
