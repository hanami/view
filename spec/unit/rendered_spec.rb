# frozen_string_literal: true

require "hanami/view/rendered"

RSpec.describe Hanami::View::Rendered do
  subject(:rendered) {
    described_class.new(
      output: "rendered template output",
      locals: {
        user: {name: "Jane"}
      }
    )
  }

  describe "#to_s" do
    it "returns the rendered output" do
      expect(rendered.to_s).to eq "rendered template output"
    end
  end

  describe "#to_str" do
    it "returns the rendered output" do
      expect(rendered.to_str).to eq "rendered template output"
    end
  end

  describe "#locals" do
    it "returns the locals hash" do
      expect(rendered.locals).to eql(user: {name: "Jane"})
    end
  end

  describe "#[]" do
    it "returns the named local" do
      expect(rendered[:user]).to eql(name: "Jane")
    end
  end
end
