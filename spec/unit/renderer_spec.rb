# frozen_string_literal: true

require "hanami/view/path"
require "hanami/view/renderer"

RSpec.describe Hanami::View::Renderer do
  subject(:renderer) do
    Hanami::View::Renderer.new(
      [Hanami::View::Path.new(SPEC_ROOT.join("fixtures/templates"))],
      format: "html",
      default_encoding: "utf-8"
    )
  end

  let(:scope) { double(:scope) }

  describe "#template" do
    it "renders template in current directory" do
      expect(renderer.template(:hello, scope)).to eql("<h1>Hello</h1>")
    end

    it "does not include `shared/` subdirectory under root when looking up templates" do
      expect {
        renderer.template(:_shared_hello, scope)
      }.to raise_error(Hanami::View::TemplateNotFoundError, /_shared_hello/)
    end

    it "raises error when template cannot be found" do
      expect {
        renderer.template(:missing_template, scope)
      }.to raise_error(Hanami::View::TemplateNotFoundError, /missing_template/)
    end
  end

  describe "#partial" do
    it "renders partial in current directory" do
      expect(renderer.partial(:hello, scope)).to eql("<h1>Partial hello</h1>")
    end

    it "renders partial in shared/ subdirectory under root" do
      expect(renderer.chdir("hello").partial(:shared_hello, scope)).to eql("<h1>Hello</h1>")
    end

    it "renders partial in shared/ subdirectory when descending from an upper directory" do
      expect(renderer.chdir("hello").partial(:shared_hello, scope)).to eql("<h1>Hello</h1>")
    end

    it "renders partial in upper directory" do
      expect(renderer.chdir("nested").partial(:hello, scope)).to eql("<h1>Partial hello</h1>")
    end

    it "renders partial in upper shared/ subdirectory" do
      expect(renderer.chdir("nested").partial(:shared_hello, scope)).to eql("<h1>Hello</h1>")
    end

    it "raises error when partial cannot be found" do
      expect {
        renderer.partial(:missing_partial, scope)
      }.to raise_error(Hanami::View::TemplateNotFoundError, /_missing_partial/)
    end
  end

  describe "#chdir" do
    it "copies options to new renderer instance" do
      expect(renderer.chdir("nested").options).to eq(default_encoding: "utf-8")
    end
  end
end
