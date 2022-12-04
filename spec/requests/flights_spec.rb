# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Flights" do
  let(:pilot) { create :pilot }

  describe "GET /flights" do
    before :each do
      @flights = create_list(:flight, 10, pilot:)
      # red herrings
      create :flight
      create :flight, pilot:, date: 2.weeks.ago
    end

    it "redirects when not logged in" do
      get flights_url
      expect(response).to redirect_to(new_pilot_session_url)
    end

    it "loads flights" do
      sign_in pilot
      get flights_url
      expect(response).to have_http_status(:success)
      expect(assigns(:flights)).to match_array(@flights)
    end
  end

  describe "GET /flights/:id" do
    let(:flight) { create :flight, pilot: }
    let(:url) { flight_url(flight) }

    it "renders the 'show' action if not signed in" do
      get url
      expect(response).to render_template("show")
      expect(assigns(:flight)).to eql(flight)
    end

    it "renders the 'show' action if signed in as a different pilot" do
      sign_in create(:pilot)
      get url
      expect(response).to render_template("show")
      expect(assigns(:flight)).to eql(flight)
    end

    it "renders the 'edit' action if signed in as the creating pilot" do
      sign_in pilot
      get url
      expect(response).to render_template("edit")
      expect(assigns(:flight)).to eql(flight)
    end
  end

  describe "GET /flights/new" do
    it "redirects if not logged in" do
      get "/flights/new"
      expect(response).to redirect_to(new_pilot_session_url)
    end

    it "renders if logged in" do
      sign_in pilot
      get "/flights/new"
      expect(response).to have_http_status(:success)
      expect(assigns(:flight)).not_to be_nil
    end
  end

  describe "POST /flights" do
    let(:flight_params) { attributes_for :flight }

    it "redirects if not logged in" do
      post "/flights", params: {flight: flight_params}
      expect(response).to redirect_to(new_pilot_session_url)
    end

    context "[logged in]" do
      before(:each) { sign_in pilot }

      it "creates a flight" do
        post "/flights", params: {flight: flight_params}
        expect(response).to be_redirect
        expect(pilot.flights.count).to be(1)
      end

      it "handles validation errors" do
        flight_params[:date] = "not a date"
        post "/flights", params: {flight: flight_params}
        expect(response).to render_template("new")
        expect(assigns(:flight).errors.size).to be(1)
      end
    end
  end

  describe "PATCH /flights/:id" do
    let(:flight) { create :flight, pilot: }
    let(:flight_params) { attributes_for :flight }
    let(:url) { flight_url(flight) }

    it "redirects if not logged in" do
      patch url, params: {flight: flight_params}
      expect(response).to redirect_to(new_pilot_session_url)
    end

    it "404s if logged in as a different pilot" do
      sign_in create(:pilot)
      patch url, params: {flight: flight_params}
      expect(response).to have_http_status(:not_found)
    end

    context "[logged in]" do
      before(:each) { sign_in pilot }

      it "updates a flight" do
        patch url, params: {flight: flight_params}
        expect(response).to redirect_to(url)
        expect(flight.reload.description).
            to eql(flight_params[:description])
      end

      it "handles validation errors" do
        flight_params[:date] = "not a date"
        patch url, params: {flight: flight_params}
        expect(response).to render_template("edit")
        expect(assigns(:flight).errors.size).to be(1)
      end
    end
  end

  describe "DELETE /flights/:id" do
    let(:flight) { create :flight, pilot: }
    let(:url) { flight_url(flight) }

    it "redirects if not logged in" do
      delete url
      expect(response).to redirect_to(new_pilot_session_url)
    end

    it "404s if logged in as a different pilot" do
      sign_in create(:pilot)
      delete url
      expect(response).to have_http_status(:not_found)
    end

    context "[logged in]" do
      before(:each) { sign_in pilot }

      it "deletes a flight" do
        delete url
        expect(response).to redirect_to(flights_url)
        expect { flight.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
