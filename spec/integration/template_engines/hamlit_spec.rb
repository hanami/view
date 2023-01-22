# frozen_string_literal: true

require "hanami/view"
require "hanami/view/context"

RSpec.describe "Template engines / haml (using hamlit-block as default engine)" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/hamlit")
    end
  }

  context "with hamlit-block available" do
    it "supports partials that yield" do
      view = Class.new(base_view) do
        config.template = "render_and_yield"
      end.new

      expect(view.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
    end

    it "supports methods that yield" do
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

  context "with hamlit not available" do
    before do
      @load_path = $LOAD_PATH.dup
      @loaded_features = $LOADED_FEATURES.dup

      $LOAD_PATH.reject! { |path| path =~ /hamlit/ }
      $LOADED_FEATURES.reject! { |path| path =~ /hamlit/ }

      Hanami::View.cache.clear
    end

    after do
      $LOAD_PATH.replace @load_path
      $LOADED_FEATURES.replace @loaded_features
    end

    it "raises an error explaining the hamlit requirement" do
      view = Class.new(base_view) do
        config.template = "render_and_yield"
      end.new

      expect { view.() }.to raise_error(LoadError, /hanami-view requires hamlit/m)
    end
  end
end
