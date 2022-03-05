require 'rails_helper'

RSpec.describe 'Passengers', type: :request do
  let(:pilot) { create :pilot }
  let(:flight) { create :flight, pilot: }

  describe 'GET /flights/:flight_id/passengers/:id' do
    let(:passenger) { create :passenger, flight: }
    let(:url) { flight_passenger_url(flight, passenger) }

    it "renders the 'show' action if not signed in" do
      get url
      expect(response).to have_http_status(:success)
      expect(assigns(:flight)).to eql(flight)
      expect(assigns(:passenger)).to eql(passenger)
    end

    it "redirects to the flight page if signed in" do
      sign_in pilot
      get url
      expect(response).to redirect_to(flight_url(flight))
    end

    it "renders the 'show' action if signed in as someone else" do
      sign_in create(:pilot)
      get url
      expect(response).to have_http_status(:success)
      expect(assigns(:flight)).to eql(flight)
      expect(assigns(:passenger)).to eql(passenger)
    end
  end

  describe 'POST /flights/:flight_id/passengers' do
    let(:pax_params) { attributes_for :passenger }
    let(:url) { flight_passengers_url(flight) }

    context '[logged out]' do
      it "adds a passenger" do
        post url, params: {passenger: pax_params}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
      end

      it "adds a passenger without bags" do
        post url, params: {passenger: pax_params.merge(bags_weight: '')}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
        expect(flight.passengers.first.bags_weight).to be_zero
      end

      it "handles validation errors" do
        pax_params[:weight] = 'not a number'
        pax_params[:bags_weight] = 'not a number'
        post url, params: {passenger: pax_params}
        expect(response).to render_template('flights/show')
        expect(assigns(:passenger).errors.size).to be(4)
      end

      it "updates an existing passenger with the same name" do
        pax = create(:passenger, name: "Sancho Sample", weight: 120)
        pax_params[:name] = "Sancho Sample"
        post url, params: {passenger: pax_params}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
        expect(pax.reload.weight).to be(120)
      end
    end

    context '[logged in as someone else]' do
      before(:each) { sign_in create(:pilot) }

      it "adds a passenger" do
        post url, params: {passenger: pax_params}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
      end

      it "adds a passenger without bags" do
        post url, params: {passenger: pax_params.merge(bags_weight: '')}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
        expect(flight.passengers.first.bags_weight).to be_zero
      end

      it "handles validation errors" do
        pax_params[:weight] = 'not a number'
        pax_params[:bags_weight] = 'not a number'
        post url, params: {passenger: pax_params}
        expect(response).to render_template('flights/show')
        expect(assigns(:passenger).errors.size).to be(4)
      end

      it "updates an existing passenger with the same name" do
        pax = create(:passenger, name: "Sancho Sample", weight: 120)
        pax_params[:name] = "Sancho Sample"
        post url, params: {passenger: pax_params}
        expect(response).to redirect_to(flight_passenger_url(flight, flight.passengers.first))
        expect(flight.passengers.count).to be(1)
        expect(pax.reload.weight).to be(120)
      end
    end

    context '[logged in]' do
      before(:each) { sign_in pilot }

      it "adds a passenger" do
        post url, params: {passenger: pax_params}
        expect(response).to redirect_to(flight_url(flight))
        expect(flight.passengers.count).to be(1)
      end

      it "adds a passenger without bags" do
        post url, params: {passenger: pax_params.merge(bags_weight: '')}
        expect(response).to redirect_to(flight_url(flight))
        expect(flight.passengers.count).to be(1)
        expect(flight.passengers.first.bags_weight).to be_zero
      end

      it "handles validation errors" do
        pax_params[:weight] = 'not a number'
        pax_params[:bags_weight] = 'not a number'
        post url, params: {passenger: pax_params}
        expect(response).to render_template('flights/edit')
        expect(assigns(:passenger).errors.size).to be(4)
      end
    end
  end

  describe 'DELETE /flights/:flight_id/passengers/:id' do
    let(:passenger) { create :passenger, flight: }
    let(:url) { flight_passenger_url(flight, passenger) }

    it "redirects if not logged in" do
      delete url
      expect(response).to redirect_to(new_pilot_session_url)
    end

    it "404s if logged in as a different pilot" do
      sign_in create(:pilot)
      delete url
      expect(response).to have_http_status(:not_found)
    end

    context '[logged in]' do
      before(:each) { sign_in pilot }

      it "deletes a passenger" do
        delete url
        expect(response).to redirect_to(flight_url(flight))
        expect { passenger.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
