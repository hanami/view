RSpec.describe "Template engines / erb (Hanami::View::ERB)" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/erb")
    end
  }

  it "automatically escapes non-html_safe strings" do
    view = Class.new(base_view) do
      config.template = "escaping"

      expose :name
    end.new

    expect(view.(name: "<span>Jane</span>").to_s.strip).to eq "&lt;span&gt;Jane&lt;/span&gt;"
    expect(view.(name: "<span>Jane</span>".html_safe).to_s.strip).to eq "<span>Jane</span>"
  end

  it "supports partials that yield" do
    view = Class.new(base_view) do
      config.template = "render_and_yield"
    end.new

    expect(view.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end

  it "supports context methods that yield" do
    context = Class.new(Hanami::View::Context) do
      def wrapper
        "<wrapper>#{yield}</wrapper>".html_safe
      end
    end.new

    view = Class.new(base_view) do
      config.default_context = context
      config.template = "method_with_yield"
    end.new

    expect(view.().to_s.gsub(/\n\s*/m, "")).to eq "<wrapper>Yielded</wrapper>"
  end
end
