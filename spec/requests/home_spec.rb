require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it "redirects if logged in" do
      sign_in create(:pilot)
      get '/'
      expect(response).to redirect_to(flights_url)
    end

    it "renders the login and signup pages" do
      get '/'
      expect(response).to have_http_status(:success)
      expect(assigns(:pilot)).to be_a(Pilot)
    end
  end
end
