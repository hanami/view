# frozen_string_literal: true

require "erubi"
require "erubi/capture_end"
require "tilt/erubi"

require "hanami/view"
require "hanami/view/context"

RSpec.describe "Template engines / erb (using erubi via an explict engine mapping)" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/erubi")
      config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}
      config.renderer_options = {engine_class: Erubi::CaptureEndEngine}
    end
  }

  it "supports partials that yield" do
    view = Class.new(base_view) do
      config.template = "render_and_yield"
    end.new

    expect(view.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end

  it "supports context methods that yield" do
    context = Class.new(Hanami::View::Context) do
      def wrapper
        "<wrapper>#{yield}</wrapper>"
      end
    end.new

    view = Class.new(base_view) do
      config.default_context = context
      config.template = "method_with_yield"
    end.new

    expect(view.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end
end
