# frozen_string_literal: true

require "hanami/view"
require "hanami/view/context"

RSpec.describe "View / Rendering / Context reuse" do
  specify "Context state set in template is available when rendering layout" do
    view = Class.new(Hanami::View) do
      config.paths = SPEC_ROOT.join("fixtures/integration/view/rendering/context_reuse")
      config.template = "template"
      config.layout = "application"
    end.new

    context = Class.new(Hanami::View::Context) do
      def page_title(title = (no_args = true))
        if no_args
          _options[:page_title] || "Default title"
        else
          _options[:page_title] = title
        end
      end
    end.new

    output = view.(context: context).to_s

    expect(output).to eq "<title>Title from template</title>"
  end
end
