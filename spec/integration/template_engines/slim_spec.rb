# frozen_string_literal: true

require "slim"
require "hanami/view"
require "hanami/view/context"
require "hanami/view/slim/template"

RSpec.describe "Template engines / slim" do
  let(:base_view) {
    Class.new(Hanami::View) do
      config.paths = FIXTURES_PATH.join("integration/template_engines/slim")
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

    expect(view.().to_s).to eq "<wrapper>Yielded</wrapper>"
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

    expect(view.().to_s).to eq "<wrapper>Yielded</wrapper>"
  end

  it "marks captured block content as HTML safe" do
    scope = Class.new {
      def html_safe_capture
        yield.html_safe?
      end
    }.new

    src = <<~SLIM
      = html_safe_capture do
        div Some content
        div goes here.
    SLIM

    output = Hanami::View::SlimAdapter::Template.new { src }.render(scope)

    expect(output.strip).to eq "true"
  end
end
