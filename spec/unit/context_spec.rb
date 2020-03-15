# frozen_string_literal: true

require "hanami/view/context"
require "hanami/view/part"
require "hanami/view/part_builder"
require "hanami/view/scope_builder"

RSpec.describe Hanami::View::Context do
  let(:context_class) {
    Class.new(Hanami::View::Context) do
      attr_reader :assets, :routes

      decorate :assets, :routes
      decorate :invalid_attribute

      def initialize(assets:, routes:, **options)
        @assets = assets
        @routes = routes
        super
      end
    end
  }

  let(:assets) { double(:assets) }
  let(:routes) { double(:routes) }

  let(:render_env) {
    Hanami::View::RenderEnvironment.new(
      inflector: Dry::Inflector.new,
      renderer: double(:renderer),
      context: Hanami::View::Context.new,
      part_builder: Hanami::View::PartBuilder.new,
      scope_builder: Hanami::View::ScopeBuilder.new
    )
  }

  subject(:context) { context_class.new(assets: assets, routes: routes) }

  describe "attribute readers" do
    it "provides access to its attributes" do
      expect(context.assets).to eql assets
    end
  end

  context "with render environment" do
    subject(:context) {
      context_class.new(assets: assets, routes: routes).for_render_env(render_env)
    }

    describe "attribute readers" do
      it "provides attributes decorated in view parts" do
        expect(context.assets).to be_a Hanami::View::Part
        expect(context.assets.value).to eql assets
      end
    end
  end

  describe "#with" do
    it "returns a copy of the context with extra options" do
      another_option = double(:another_option)
      new_context = context.with(another_option: another_option)

      expect(new_context).to be_a(context.class)
      expect(new_context._options).to eq(assets: context.assets, routes: routes, another_option: another_option)
    end
  end
end
