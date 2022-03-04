require 'rails_helper'

RSpec.describe Flight, type: :model do
  describe '[hooks]' do
    it "has a UUID" do
      expect(create(:flight).uuid).not_to be_nil
    end
  end
end
