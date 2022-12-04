# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations" do
  describe "GET /pilots/sign_up" do
    it "redirects to the home page" do
      get "/pilots/sign_up"
      expect(response).to redirect_to(root_url)
    end
  end

  describe "POST /pilots" do
    let(:pilot_params) { attributes_for :pilot }

    it "creates a new pilot" do
      post "/pilots", params: {pilot: pilot_params}
      expect(response).to redirect_to(flights_url)
      expect(controller).to be_pilot_signed_in
    end

    it "handles validation errors" do
      pilot_params[:password] = "1"
      post "/pilots", params: {pilot: pilot_params}
      expect(response).to render_template("index")
      expect(controller).not_to be_pilot_signed_in
      expect(assigns(:minimum_password_length)).to be(6)
      expect(assigns(:pilot).password).to be_blank
      expect(assigns(:pilot).password_confirmation).to be_blank
    end
  end

  describe "PATCH /pilots" do
    let(:pilot) { create :pilot, password: "supersekret" }
    let(:pilot_params) do
      attributes_for(:pilot).merge(current_password: "supersekret")
    end

    before(:each) { sign_in pilot }

    it "updates the pilot" do
      patch "/pilots", params: {pilot: pilot_params}
      expect(response).to redirect_to(flights_url)
      expect(controller).to be_pilot_signed_in
      expect(pilot.reload.name).to eql(pilot_params[:name])
    end

    it "handles validation errors" do
      pilot_params[:password] = "1"
      patch "/pilots", params: {pilot: pilot_params}
      expect(response).to render_template("home/index")
      expect(assigns(:minimum_password_length)).to be(6)
      expect(assigns(:pilot).password).to be_blank
      expect(assigns(:pilot).password_confirmation).to be_blank
    end
  end
end
