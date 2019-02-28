# frozen_string_literal: true

RSpec.describe Hanami::View do
  subject do
    Class.new(described_class).new
  end

  describe "#initialize" do
    it "returns instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end

    it "returns a frozen instance" do
      expect(subject.frozen?).to be(true)
    end
  end

  describe "#name" do
    it "returns nil for anonymous classes" do
      expect(subject.name).to be(nil)
    end

    it "returns standardized name" do
      subject = Web::Views::Home::Index.new
      expect(subject.name).to eq("web.views.home.index")
    end

    it "returns a frozen value" do
      subject = Web::Views::Home::Index.new
      expect(subject.name.frozen?).to be(true)
    end
  end

  describe "#call" do
    subject { Web::Views::Home::Index.new }

    it "renders template" do
      output = subject.call({}).to_s

      expect(output).to include(%(<title>Web app</title>))
      expect(output).to include(%(hello))
    end
  end
end
