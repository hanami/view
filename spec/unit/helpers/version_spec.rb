# frozen_string_literal: true

RSpec.describe "Hanami::Helpers::VERSION" do
  it "exposes version" do
    expect(Hanami::Helpers::VERSION).to eq("2.0.0.alpha1")
  end
end
