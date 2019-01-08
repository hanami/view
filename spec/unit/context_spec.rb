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

  let(:rendering) {
    Dry::View::Rendering.new(
      inflector: Dry::Inflector.new,
      renderer: double(:renderer),
      context: Dry::View::Context.new,
      part_builder: Dry::View::PartBuilder.new,
      scope_builder: Dry::View::ScopeBuilder.new,
    )
  }

  subject(:context) { context_class.new(assets: assets, routes: routes) }

  it { is_expected.not_to be_rendering }

  describe "attribute readers" do
    it "provides access to its attributes" do
      expect(context.assets).to eql assets
    end

    it "raises NoMethodError when an invalid attribute is accessed" do
      expect { context.invalid_attribute }.to raise_error(NoMethodError)
    end
  end

  context "for rendering" do
    subject(:context) {
      context_class.new(assets: assets, routes: routes).for_rendering(rendering)
    }

    it { is_expected.to be_rendering }

    describe "attribute readers" do
      it "provides attributes decorated in view parts" do
        expect(context.assets).to be_a Dry::View::Part
        expect(context.assets.value).to eql assets
      end

      it "raises NoMethodError when an invalid attribute is decorated" do
        expect { context.invalid_attribute }.to raise_error(NoMethodError)
      end

      it "stores the decorated attribute readers in a single decorated attributes module" do
        expect(context_class.ancestors[0].inspect).to eq "#<Dry::View::Context::DecoratedAttributes[:assets, :invalid_attribute, :routes]>"
      end
    end
  end

  describe "#with" do
    it "returns a copy of the context with extra options" do
      another_option = double(:another_option)
      new_context = context.with(another_option: another_option)

      expect(new_context).to be_a(context.class)
      expect(new_context._options).to eq({assets: context.assets, routes: routes, another_option: another_option})
    end
  end
end
