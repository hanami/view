RSpec.describe 'parts' do
  describe 'custom decorator and part classes' do
    before do
      module Test
        class CustomPart < Dry::View::Part
          def to_s
            "Custom part wrapping #{_object}"
          end
        end
      end
    end

    it 'wraps objects in custom parts' do
      decorator = Class.new(Dry::View::Decorator) do
        def part_class(name, options)
          name == :custom ? Test::CustomPart : super
        end
      end.new

      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.decorator = decorator
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :custom, :ordinary
      end.new

      expect(vc.(custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end
end
