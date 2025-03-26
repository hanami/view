# frozen_string_literal: true

RSpec.describe Hanami::View::DecoratedAttributes do
  subject(:decoratable) {
    Test::Decoratable = Struct.new(:attr_1, :attr_2, :_rendering) do
      include Hanami::View::DecoratedAttributes

      decorate :attr_1, as: :my_value
      decorate :attr_2
      decorate :invalid_attr
    end

    Test::Decoratable.new(attr_1, attr_2, rendering)
  }

  let(:attr_1) { double(:attr_1) }
  let(:attr_2) { double(:attr_2) }
  let(:rendering) { instance_spy(Hanami::View::Rendering) }

  context "with rendering" do
    it "returns decorated attributes as parts" do
      decoratable.attr_1
      expect(rendering).to have_received(:part).with(:attr_1, attr_1, as: :my_value)

      decoratable.attr_2
      expect(rendering).to have_received(:part).with(:attr_2, attr_2)
    end

    it "raises NoMethodError when an invalid attribute is accessed" do
      expect { decoratable.invalid_attr }.to raise_error(NoMethodError)
    end
  end

  context "without rendering" do
    let(:rendering) { nil }

    it "returns attributes without decoration" do
      expect(decoratable.attr_1).to be attr_1
    end

    it "raises NoMethodError when an invalid attribute is accessed" do
      expect { decoratable.invalid_attr }.to raise_error(NoMethodError)
    end
  end

  it "prepends a single module to provide the decorated attribute readers" do
    expect(decoratable.class.ancestors.map(&:name).grep(/Test::Decoratable::DecoratedAttributes/).length).to eq 1
    expect(decoratable.class.ancestors[0].inspect).to eq "#<Hanami::View::DecoratedAttributes::Attributes[:attr_1, :attr_2, :invalid_attr]>"
  end
end
