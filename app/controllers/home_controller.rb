# frozen_string_literal: true

# Controller for the logged-out home page.

class HomeController < ApplicationController
  include Devise::Controllers::Helpers

  before_action :redirect_if_logged_in

  # Renders the logged-out home page, which includes the login and signup forms.
  # Redirects to the flights list if the session is authenticated.
  #
  # Routes
  # ------
  #
  # * `GET /`

  def index
    @pilot = Pilot.new(sign_in_params)
    @pilot.clean_up_passwords if @pilot.respond_to?(:clean_up_passwords)
  end

  protected

  # @private
  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  # @private
  def resource_class = Pilot

  # @private
  def resource_name = :pilot

  private

  def redirect_if_logged_in
    if pilot_signed_in?
      respond_to do |format|
        format.html { redirect_to flights_url }
      end
      return false
    end
    return true
  end
end
