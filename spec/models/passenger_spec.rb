# frozen_string_literal: true

require "rails_helper"

RSpec.describe Passenger do
  context "[validations]" do
    it "validates that at least one weight is > 0" do
      expect(build(:passenger, weight: 0, bags_weight: 0)).to be_invalid
      expect(build(:passenger, weight: 1, bags_weight: 0)).to be_valid
      expect(build(:passenger, weight: 0, bags_weight: 1)).to be_valid
      expect(build(:passenger, weight: 1, bags_weight: 1)).to be_valid
    end
  end

  describe "#baggage?" do
    it "returns true if pilot weight is 0" do
      expect(create(:passenger, weight: 0, bags_weight: 1)).to be_baggage
    end

    it "returns false if pilot weight is > 0" do
      expect(create(:passenger, weight: 1, bags_weight: 1)).not_to be_baggage
    end
  end

  describe "#passenger?" do
    it "returns false if pilot weight is 0" do
      expect(create(:passenger, weight: 0, bags_weight: 1)).not_to be_passenger
    end

    it "returns true if pilot weight is > 0" do
      expect(create(:passenger, weight: 1, bags_weight: 1)).to be_passenger
    end
  end
end
