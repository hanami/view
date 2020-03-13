# frozen_string_literal: true

require "dry/view/context"
require "dry/view/part"
require "dry/view/part_builder"
require "dry/view/scope_builder"

RSpec.describe Dry::View::Context do
  let(:context_class) {
    Class.new(Dry::View::Context) do
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
    Dry::View::RenderEnvironment.new(
      inflector: Dry::Inflector.new,
      renderer: double(:renderer),
      context: Dry::View::Context.new,
      part_builder: Dry::View::PartBuilder.new,
      scope_builder: Dry::View::ScopeBuilder.new
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
        expect(context.assets).to be_a Dry::View::Part
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
