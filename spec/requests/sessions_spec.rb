require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /pilots/sign_in' do
    it "redirects to the home page" do
      get new_pilot_session_url
      expect(response).to redirect_to(root_url)
    end
  end

  describe 'POST /pilots/sign_in' do
    let(:password) { 'password123' }
    let(:pilot) { FactoryBot.create :pilot, password: password }
    let(:params) { {pilot: {email: pilot.email, password: password}} }

    it "signs in a pilot" do
      post pilot_session_url, params: params
      expect(controller).to be_pilot_signed_in
      expect(response).to redirect_to(flights_url)
    end

    it "rejects bad credentials" do
      params[:pilot][:password] = 'incorrect'
      post pilot_session_url, params: params
      expect(response).to render_template('home/index')
      expect(controller).not_to be_pilot_signed_in
    end
  end
end
