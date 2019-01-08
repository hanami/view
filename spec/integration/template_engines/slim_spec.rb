require "slim"
require "dry/view/context"
require "dry/view/controller"

RSpec.describe "Template engines / slim" do
  let(:base_vc) {
    Class.new(Dry::View::Controller) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/slim")
    end
  }

  it "supports partials that yield" do
    vc = Class.new(base_vc) do
      config.template = "render_and_yield"
    end.new

    expect(vc.().to_s).to eq "<wrapper>Yielded</wrapper>"
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

    expect(vc.().to_s).to eq "<wrapper>Yielded</wrapper>"
  end
end
