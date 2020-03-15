# frozen_string_literal: true

RSpec.describe Hanami::View::Exposures do
  subject(:exposures) { described_class.new }

  describe "#exposures" do
    it "is empty by defalut" do
      expect(exposures.exposures).to be_empty
    end
  end

  describe "#add" do
    it "creates and adds an exposure" do
      proc = -> **_input { "hi" }
      exposures.add :hello, proc

      expect(exposures[:hello].name).to eq :hello
      expect(exposures[:hello].proc).to eq proc
    end
  end

  describe "#bind" do
    subject(:bound_exposures) { exposures.bind(object) }

    let(:object) do
      Class.new do
        def hello(_input)
          "hi"
        end
      end.new
    end

    before do
      exposures.add(:hello)
    end

    it "binds each of the exposures" do
      expect(bound_exposures[:hello].proc).to eq object.method(:hello)
    end

    it "returns a new copy of the exposures" do
      expect(exposures.exposures).not_to eql(bound_exposures.exposures)
    end
  end

  describe "#call" do
    describe "in general" do
      before do
        exposures.add(:greeting, -> greeting: { greeting.upcase })
        exposures.add(:farewell, -> greeting { "#{greeting} and goodbye" })
      end

      subject(:locals) { exposures.(greeting: "hello") }

      it "returns the values from calling the exposures" do
        expect(locals).to eq(greeting: "HELLO", farewell: "HELLO and goodbye")
      end

      it "does not include values from private exposures" do
        exposures.add(:hidden, -> **_input { "shh" }, private: true)

        expect(locals).to include(:greeting, :farewell)
        expect(locals).not_to include(:hidden)
      end
    end

    describe "with block provided" do
      before do
        exposures.add(:greeting, -> greeting: { greeting.upcase })
        exposures.add(:farewell, -> greeting { "#{greeting} and goodbye" })
      end

      subject(:locals) {
        exposures.(greeting: "hello") do |value, exposure|
          "#{value} from #{exposure.name}"
        end
      }

      it "provides values determined from the block" do
        expect(locals).to eq(
          greeting: "HELLO from greeting",
          farewell: "HELLO from greeting and goodbye from farewell"
        )
      end
    end

    describe "with default exposure values" do
      it "returns 'default_value' from exposure" do
        exposures.add(:name, default: "John")
        locals = exposures.({})

        expect(locals).to eq(name: "John")
      end

      it "returns values from arguments" do
        exposures.add(:name, default: "John")
        locals = exposures.(name: "William")

        expect(locals).to eq(name: "William")
      end

      it "returns values from arguments even when value is nil" do
        exposures.add(:name, default: "John")
        locals = exposures.(name: nil)

        expect(locals).to eq(name: nil)
      end

      it "returns value from proc" do
        exposures.add(:name, -> name: { name.upcase }, default: "John")
        locals = exposures.(name: "William")

        expect(locals).to eq(name: "WILLIAM")
      end
    end
  end

  describe "#import" do
    it "imports an exposure to the set" do
      exposures_b = described_class.new
      exposures.add(:name, -> name: { name.upcase }, default: "John")
      exposures_b.import(:name, exposures[:name])

      expect(exposures_b[:name]).to eq(exposures[:name])
    end
  end
end
