require "erubi"
require "erubi/capture_end"
require "tilt/erubi"

require "dry/view/context"
require "dry/view/controller"

RSpec.describe "Template engines / erb (using erubi via an explict engine mapping)" do
  let(:base_vc) {
    Class.new(Dry::View::Controller) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/erubi")
      config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}
      config.renderer_options = {engine_class: Erubi::CaptureEndEngine}
    end
  }

  it "supports partials that yield" do
    vc = Class.new(base_vc) do
      config.template = "render_and_yield"
    end.new

    expect(vc.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end

  it "supports context methods that yield" do
    context = Class.new(Dry::View::Context) do
      def wrapper
        "<wrapper>#{yield}</wrapper>"
      end
    end.new

    vc = Class.new(base_vc) do
      config.default_context = context
      config.template = "method_with_yield"
    end.new

    expect(vc.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end
end