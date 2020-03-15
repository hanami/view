# frozen_string_literal: true

RSpec.describe "part builder" do
  before do
    module Test
      class Custom < Hanami::View::Part
        def to_s
          "Custom part wrapping #{_value}"
        end
      end

      CustomPart = Custom

      class CustomArrayPart < Hanami::View::Part
        def each(&block)
          (_value * 2).each(&block)
        end
      end
    end
  end

  describe "default decorator" do
    it "looks up classes from a part namespace" do
      view = Class.new(Hanami::View) do
        config.paths = SPEC_ROOT.join("fixtures/templates")
        config.layout = nil
        config.template = "decorated_parts"
        config.part_namespace = Test

        expose :customs
        expose :custom
        expose :ordinary
      end.new

      expect(view.(customs: ["many things"], custom: "custom thing", ordinary: "ordinary thing").to_s).to eql(
        "<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>"
      )
    end

    it "supports wrapping array memebers in custom part classes provided to exposure :as option" do
      view = Class.new(Hanami::View) do
        config.paths = SPEC_ROOT.join("fixtures/templates")
        config.layout = nil
        config.template = "decorated_parts"

        expose :customs, as: Test::CustomPart
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(view.(customs: ["many things"], custom: "custom thing", ordinary: "ordinary thing").to_s).to eql(
        "<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>"
      )
    end

    it "supports wrapping an array and its members in custom part classes provided to exposure :as option as a hash" do
      view = Class.new(Hanami::View) do
        config.paths = SPEC_ROOT.join("fixtures/templates")
        config.layout = nil
        config.template = "decorated_parts"

        expose :customs, as: [Test::CustomArrayPart, Test::CustomPart]
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(view.(customs: ["many things"], custom: "custom thing", ordinary: "ordinary thing").to_s).to eql(
        "<p>Custom part wrapping many things</p><p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>"
      )
    end
  end

  describe "custom decorator and part classes" do
    it "supports wrapping in custom parts based on exposure names" do
      part_builder = Class.new(Hanami::View::PartBuilder) do
        def part_class(name:, **options)
          name == :custom ? Test::CustomPart : super
        end
      end

      view = Class.new(Hanami::View) do
        config.part_builder = part_builder
        config.paths = SPEC_ROOT.join("fixtures/templates")
        config.layout = nil
        config.template = "decorated_parts"

        expose :customs, :custom, :ordinary
      end.new

      expect(view.(customs: ["many things"], custom: "custom thing", ordinary: "ordinary thing").to_s).to eql(
        "<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>"
      )
    end
  end
end
