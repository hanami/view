RSpec.describe 'part builder' do
  before do
    module Test
      class Custom < Dry::View::Part
        def to_s
          "Custom part wrapping #{_value}"
        end
      end

      CustomPart = Custom

      class CustomArrayPart < Dry::View::Part
        def each(&block)
          (_value * 2).each(&block)
        end
      end
    end
  end

  describe 'default decorator' do
    it 'looks up classes from a part namespace' do
      vc = Class.new(Dry::View::Controller) do
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = nil
        config.template = 'decorated_parts'
        config.part_namespace = Test

        expose :customs
        expose :custom
        expose :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing').to_s).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end

    it 'supports wrapping array memebers in custom part classes provided to exposure :as option' do
      vc = Class.new(Dry::View::Controller) do
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = nil
        config.template = 'decorated_parts'

        expose :customs, as: Test::CustomPart
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing').to_s).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end

    it 'supports wrapping an array and its members in custom part classes provided to exposure :as option as a hash' do
      vc = Class.new(Dry::View::Controller) do
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = nil
        config.template = 'decorated_parts'

        expose :customs, as: [Test::CustomArrayPart, Test::CustomPart]
        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing').to_s).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end

  describe 'custom decorator and part classes' do
    it 'supports wrapping in custom parts based on exposure names' do
      part_builder = Class.new(Dry::View::PartBuilder) do
        def part_class(name:, **options)
          name == :custom ? Test::CustomPart : super
        end
      end

      vc = Class.new(Dry::View::Controller) do
        config.part_builder = part_builder
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = nil
        config.template = 'decorated_parts'

        expose :customs, :custom, :ordinary
      end.new

      expect(vc.(customs: ['many things'], custom: 'custom thing', ordinary: 'ordinary thing').to_s).to eql(
        '<p>Custom part wrapping many things</p><p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end
end
