# frozen_string_literal: true

require "hanami/view"
require "hanami/view/context"

RSpec.describe "View / exposures" do
  specify "exposures have access to context" do
    view = Class.new(Hanami::View) {
      config.paths = SPEC_ROOT.join("fixtures/templates")
      config.template = "greeting"

      expose :greeting do |greeting:, context:|
        "#{greeting}, #{context.name}"
      end
    }.new

    context = Class.new(Hanami::View::Context) {
      def name
        "Jane"
      end
    }.new

    local = view.(greeting: "Hello", context: context).locals[:greeting]

    expect(local.value).to eq "Hello, Jane"
  end
end
