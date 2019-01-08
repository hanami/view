require "dry/view/context"
require "dry/view/controller"

RSpec.describe "Template engines / haml (using hamlit-block as default engine)" do
  let(:base_vc) {
    Class.new(Dry::View::Controller) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/hamlit")
    end
  }

  context "with hamlit-block available" do
    it "supports partials that yield" do
      vc = Class.new(base_vc) do
        config.template = "render_and_yield"
      end.new

      expect(vc.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
    end

    it "supports methods that yield" do
      context = Class.new(Dry::View::Context) do
        def wrapper(&block)
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

  context "with hamlit-block not available" do
    before do
      @load_path = $LOAD_PATH.dup
      @loaded_features = $LOADED_FEATURES.dup

      $LOAD_PATH.reject! { |path| path =~ /hamlit-block/ }
      $LOADED_FEATURES.reject! { |path| path =~ /hamlit-block/ }

      Dry::View::Tilt.cache.clear
      Dry::View::Renderer.cache.clear
    end

    after do
      $LOAD_PATH.replace @load_path
      $LOADED_FEATURES.replace @loaded_features
    end

    it "raises an error explaining the hamlit-block requirement" do
      vc = Class.new(base_vc) do
        config.template = "render_and_yield"
      end.new

      expect { vc.() }.to raise_error(LoadError, %r{dry-view requires hamlit-block}m)
    end
  end
end
