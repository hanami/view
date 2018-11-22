require "dry/view/context"
require "dry/view/part"
require "dry/view/part_builder"
require "dry/view/scope_builder"

RSpec.describe Dry::View::Context do
  let(:context_class) {
    Class.new(Dry::View::Context) do
      attr_reader :assets

      decorate :assets, :invalid_attribute

      def initialize(assets:, **options)
        @assets = assets
        super
      end
    end
  }

  let(:assets) { double(:assets) }
  let(:renderer) { double(:renderer) }
  let(:part_builder) { Dry::View::PartBuilder.new(scope_builder: scope_builder) }
  let(:scope_builder) { Dry::View::ScopeBuilder.new }

  it "provides a helpful #inspect on the generated decorated attributes module" do
    expect(context_class.ancestors[0].inspect).to eq "#<Dry::View::Context::DecoratedAttributes[:assets, :invalid_attribute]>"
  end

  context "unbound" do
    subject(:context) { context_class.new(assets: assets) }

    it { is_expected.not_to be_bound }

    it "returns its attributes" do
      expect(context.assets).to eql assets
    end

    it "raises NoMethodError when an invalid attribute is decorated" do
      expect { context.invalid_attribute }.to raise_error(NoMethodError)
    end
  end

  context "bound" do
    subject(:context) {
      context_class.new(assets: assets).
        bind(renderer: renderer, part_builder: part_builder)
    }

    it { is_expected.to be_bound }

    it "returns its assets decorated in view parts" do
      expect(context.assets).to be_a Dry::View::Part
      expect(context.assets.value).to eql assets
    end

    it "raises NoMethodError when an invalid attribute is decorated" do
      expect { context.invalid_attribute }.to raise_error(NoMethodError)
    end
  end
end
