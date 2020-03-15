# frozen_string_literal: true

require "hanami/view/decorated_attributes"

RSpec.describe Hanami::View::DecoratedAttributes do
  subject(:decoratable) {
    Test::Decoratable = Struct.new(:attr_1, :attr_2, :_render_env) do
      include Hanami::View::DecoratedAttributes

      decorate :attr_1, as: :my_value
      decorate :attr_2
      decorate :invalid_attr
    end

    Test::Decoratable.new(attr_1, attr_2, render_env)
  }

  let(:attr_1) { double(:attr_1) }
  let(:attr_2) { double(:attr_2) }
  let(:render_env) { spy(:render_env) }

  context "with render environment" do
    it "returns decorated attributes as parts" do
      decoratable.attr_1
      expect(render_env).to have_received(:part).with(:attr_1, attr_1, as: :my_value)

      decoratable.attr_2
      if RUBY_VERSION >= "2.7"
        expect(render_env).to have_received(:part).with(:attr_2, attr_2)
      else
        expect(render_env).to have_received(:part).with(:attr_2, attr_2, {})
      end
    end

    it "raises NoMethodError when an invalid attribute is accessed" do
      expect { decoratable.invalid_attr }.to raise_error(NoMethodError)
    end
  end

  context "without render environment" do
    let(:render_env) { nil }

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
