require "dry/view/rendering"

require "dry/inflector"
require "dry/view/context"
require "dry/view/part_builder"
require "dry/view/scope_builder"

RSpec.describe Dry::View::Rendering do
  subject(:rendering) { described_class.new(**rendering_options) }

  let(:rendering_options) {
    {
      inflector: Dry::Inflector.new,
      renderer: Dry::View::Renderer.new([Dry::View::Path.new(FIXTURES_PATH)], format: :html),
      context: Dry::View::Context.new,
      part_builder: Dry::View::PartBuilder.new,
      scope_builder: Dry::View::ScopeBuilder.new,
    }
  }

  describe "#format" do
    it "returns the renderer's format" do
      expect(rendering.format).to eq :html
    end
  end

  describe "#==" do
    it "is equal when its options are equal" do
      expect(rendering).to eq described_class.new(**rendering_options)
    end
  end
end
