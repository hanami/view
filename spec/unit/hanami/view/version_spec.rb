# frozen_string_literal: true

RSpec.describe "Hanami::View::VERSION" do
  it "exposes version" do
    expect(Hanami::View::VERSION).to eq("2.0.0.alpha1")
  end
end
