RSpec.describe 'parts' do
  before do
    module Test
      class SpecialPart < Dry::View::Part
        def description
          "Custom description of #{_object}"
        end
      end
    end
  end

  it 'wraps objects in parts' do
    decorator = Class.new(Dry::View::Decorator) do
      def part_class(name, options)
        name == :special ? Test::SpecialPart : super
      end
    end.new

    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.decorator = decorator
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.layout = nil
        config.template = 'decorated_parts'
      end

      expose :special
    end.new

    expect(vc.(special: 'decorated thing')).to eql '<p>Custom description of decorated thing</p>'
  end
end
