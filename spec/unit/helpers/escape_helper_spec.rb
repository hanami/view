# frozen_string_literal: true

require "hanami/view/helpers/escape_helper"

RSpec.describe Hanami::View::Helpers::EscapeHelper do
  subject(:obj) {
    Class.new {
      include Hanami::View::Helpers::EscapeHelper
    }.new
  }

  def h(&block)
    obj.instance_eval(&block)
  end

  it "includes private helpers only" do
    expect { obj.escape_html }.to raise_error(NoMethodError)
  end

  describe "#raw" do
    it "returns an HTML safe string" do
      expect(h { raw("<script>") }).to eq("<script>").and be_html_safe
    end
  end

  # See escape_hepler/escape_html_spec.rb for more thorough tests
  describe "#escape_html" do
    it "escapes HTML" do
      expect(h { escape_html("<script>") }).to eq "&lt;script&gt;"
    end

    it "is aliased as h" do
      expect(h { h("<script>") }).to eq "&lt;script&gt;"
    end
  end

  # See escape_hepler/escape_url_spec.rb for more thorough tests
  describe "#escape_url" do
    it "escapes URLs" do
      expect(h { escape_url("javascript:alert(1);") }).to eq ""
    end
  end
end
