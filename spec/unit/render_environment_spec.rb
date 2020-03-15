# frozen_string_literal: true

require "hanami/view/render_environment"

require "dry/inflector"
require "hanami/view/context"
require "hanami/view/part_builder"
require "hanami/view/scope_builder"

RSpec.describe Hanami::View::RenderEnvironment do
  subject(:render_env) { described_class.new(**options) }

  let(:options) {
    {
      inflector: Dry::Inflector.new,
      renderer: Hanami::View::Renderer.new([Hanami::View::Path.new(FIXTURES_PATH)], format: :html),
      context: Hanami::View::Context.new,
      part_builder: Hanami::View::PartBuilder.new,
      scope_builder: Hanami::View::ScopeBuilder.new
    }
  }

  describe "#format" do
    it "returns the renderer's format" do
      expect(render_env.format).to eq :html
    end
  end

  describe "#==" do
    it "is equal when its options are equal" do
      expect(render_env).to eq described_class.new(**options)
    end
  end
end
