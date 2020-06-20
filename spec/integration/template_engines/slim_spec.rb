# frozen_string_literal: true

require "slim"
require "hanami/view"
require "hanami/view/context"

RSpec.describe "Template engines / slim" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/slim")
    end
  }

  it "supports partials that yield" do
    view = Class.new(base_view) {
      config.template = "render_and_yield"
    }.new

    expect(view.().to_s).to eq "<wrapper>Yielded</wrapper>"
  end

  it "supports context methods that yield" do
    context = Class.new(Hanami::View::Context) {
      def wrapper
        "<wrapper>#{yield}</wrapper>"
      end
    }.new

    view = Class.new(base_view) {
      config.default_context = context
      config.template = "method_with_yield"
    }.new

    expect(view.().to_s).to eq "<wrapper>Yielded</wrapper>"
  end
end
