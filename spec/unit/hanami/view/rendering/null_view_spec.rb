# frozen_string_literal: true

RSpec.describe Hanami::View::Rendering::NullView do
  subject { described_class.new }

  describe "#render" do
    it "returns empty string" do
      expect(subject.render).to eq("")
    end
  end
end
