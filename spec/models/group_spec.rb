require 'spec_helper'
require_relative '../../lib/models/group'

RSpec.describe Group, type: :model do
  describe "#active?" do
    let(:group) { create(:group, enabled: true) }

    it "returns true if the group is active" do
      expect(group.active?).to be true
    end

    it "returns false if the group is inactive" do
      group.update(enabled: false)
      expect(group.active?).to be false
    end
  end
end