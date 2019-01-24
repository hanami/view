require "dry/view"
require "dry/view/context"

RSpec.describe "View / exposures" do
  specify "exposures have access to context" do
    view = Class.new(Dry::View) do
      config.paths = SPEC_ROOT.join('fixtures/templates')
      config.template = "greeting"

      expose :greeting do |greeting:, context:|
        "#{greeting}, #{context.name}"
      end
    end.new

    context = Class.new(Dry::View::Context) do
      def name
        "Jane"
      end
    end.new

    local = view.(greeting: "Hello", context: context).locals[:greeting]

    expect(local.value).to eq "Hello, Jane"
  end
end
