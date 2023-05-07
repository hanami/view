# frozen_string_literal: true

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

  # See escape_hepler/escape_html_spec.rb for complete tests
  describe "#escape_html" do
    it "escapes HTML" do
      expect(h { escape_html("<script>") }).to eq "&lt;script&gt;"
    end

    it "is aliased as h" do
      expect(h { h("<script>") }).to eq "&lt;script&gt;"
    end
  end

  describe "#escape_join" do
    def escape_join(...)
      described_class.escape_join(...)
    end

    it "escapes and joins an array of strings" do
      expect(escape_join(["<script>", "<script>"], " ")).to eq %(&lt;script&gt; &lt;script&gt;)
    end

    it "escapes the separator" do
      expect(escape_join(["a", "a"], " > ")).to eq %(a &gt; a)
    end

    it "flattens the given array" do
      expect(escape_join(["<script>", ["<script>"]], " ")).to eq %(&lt;script&gt; &lt;script&gt;)
    end

    it "does not escape HTML safe strings or separators" do
      expect(escape_join([">".html_safe, ">".html_safe], " & ".html_safe)).to eq "> & >"
    end

    it "returns an HTML safe string" do
      expect(escape_join(["<script>", "<script>"], " ")).to be_html_safe
    end
  end

  # See escape_hepler/sanitize_url_spec.rb for complete tests
  describe "#sanitize_url" do
    it "sanitizes the given URL" do
      expect(h { sanitize_url("javascript:alert(1);") }).to eq ""
    end
  end

  describe "#escape_xml_name" do
    def escape_xml_name(...)
      described_class.escape_xml_name(...)
    end

    let(:dangerous_chars) { "&<>\"' %*+,/;=^|" }

    it "replaces unsafe XML name characters with underscores" do
      expect(escape_xml_name("safe#{dangerous_chars}safe")).to eq "safe_______________safe"
    end

    it "replaces blank strings with an empty string" do
      expect(escape_xml_name("  ")).to eq ""
    end

    it "does not mark the string as HTML safe" do
      expect(escape_xml_name("name")).not_to be_html_safe
    end
  end

  describe "#raw" do
    it "returns an HTML safe string" do
      expect(h { raw("<script>") }).to eq("<script>").and be_html_safe
    end
  end
end
