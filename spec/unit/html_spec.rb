# frozen_string_literal: true

RSpec.describe Hanami::View::HTML::SafeString do
  subject(:safe_string) { described_class.new(string) }
  let(:string) { "hello" }

  it "is html_safe" do
    expect(safe_string).to be_html_safe
  end

  it "is frozen" do
    expect(safe_string).to be_frozen
  end

  it "cannot be mutated" do
    expect { safe_string.capitalize! }.to raise_error(FrozenError)
  end

  it "returns non-safe strings from methods returning new strings" do
    new_string = safe_string.gsub(/hello/, "world")
    expect(new_string).to eq "world"
    expect(new_string).not_to be_html_safe
  end

  describe "#html_safe" do
    it "returns itself" do
      expect(safe_string.html_safe).to be safe_string
    end
  end

  describe "#to_s" do
    it "returns itself" do
      expect(safe_string.to_s).to be safe_string
    end
  end

  describe "core class extensions" do
    describe "String" do
      it "is not html_safe" do
        expect("").not_to be_html_safe
      end

      it "converts to a SafeString" do
        expect("".html_safe).to be_html_safe
      end
    end

    describe "Numeric" do
      it "is html_safe" do
        expect(13).to be_html_safe
      end
    end

    describe "Object" do
      it "is not html_safe" do
        expect(Object.new).not_to be_html_safe
      end
    end
  end
end
