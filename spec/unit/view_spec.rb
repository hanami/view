# frozen_string_literal: true

require "tilt/erubi"

RSpec.describe Hanami::View do
  subject(:view) {
    Class.new(Hanami::View) {
      config.paths = SPEC_ROOT.join("fixtures/templates")
      config.layout = "app"
      config.template = "user"

      expose :user do
        {name: "Jane"}
      end

      expose :header do
        {title: "User"}
      end
    }.new
  }

  let(:context) do
    Class.new(Hanami::View::Context) {
      def title
        "Test"
      end
    }.new
  end

  describe "#call" do
    it "renders template within the layout" do
      expect(view.(context: context).to_s).to eql(
        "<!DOCTYPE html><html><head><title>Test</title></head><body><h1>User</h1><p>Jane</p></body></html>"
      )
    end
  end

  describe "renderer options" do
    subject(:view) {
      Class.new(Hanami::View) {
        config.paths = SPEC_ROOT.join("fixtures/templates")
        config.template = "view_renderer_options"
        config.renderer_engine_mapping = {erb: Tilt::ErubiTemplate}
        config.renderer_options = {outvar: "@__buf__"}
      }.new
    }

    before do
      module Test
        class Form
          def initialize(action, &block)
            @buf = eval("@__buf__", block.binding, __FILE__, __LINE__)

            @buf << "<form action=\"#{action}\" method=\"post\">"
            block.(self)
            @buf << "</form>"
          end

          def text(name)
            "<input type=\"text\" name=\"#{name}\" />"
          end
        end
      end
    end

    subject(:context) {
      Class.new(Hanami::View::Context) {
        def form(action:, &blk)
          Test::Form.new(action, &blk)
        end
      }.new
    }

    it "merges configured options with default encoding" do
      expect(view.class.config.renderer_options[:outvar]).to eq "@__buf__"
      expect(view.class.config.renderer_options[:default_encoding]).to eq "utf-8"
    end

    it "are passed to renderer" do
      expect(view.(context: context).to_s.gsub(/\n\s*/m, "")).to eq(
        '<form action="/people" method="post"><input type="text" name="name" /></form>'
      )
    end
  end
end
