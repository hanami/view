RSpec.describe Dry::View::Exposures do
  subject(:exposures) { described_class.new }

  describe "#exposures" do
    it "is empty by defalut" do
      expect(exposures.exposures).to be_empty
    end
  end

  describe "#add" do
    it "creates and adds an exposure" do
      proc = -> **input { "hi" }
      exposures.add :hello, proc

      expect(exposures[:hello].name).to eq :hello
      expect(exposures[:hello].proc).to eq proc
    end
  end

  describe "#bind" do
    subject(:bound_exposures) { exposures.bind(object) }

    let(:object) do
      Class.new do
        def hello(input)
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

  describe "#locals" do
    before do
      exposures.add(:greeting, -> greeting: { greeting.upcase })
      exposures.add(:farewell, -> greeting { "#{greeting} and goodbye" })
    end

    subject(:locals) { exposures.locals(greeting: "hello") }

    it "returns the values from the exposures' procs" do
      expect(locals).to eq(greeting: "HELLO", farewell: "HELLO and goodbye")
    end

    it "does not return any values from private exposures" do
      exposures.add(:hidden, -> **input { "shh" }, private: true)

      expect(locals).to include(:greeting, :farewell)
      expect(locals).not_to include(:hidden)
    end
  end

  describe "#locals default value" do
    it "returns 'default_value' from exposure" do
      exposures.add(:name, default: 'John')
      locals = exposures.locals({})

      expect(locals).to eq(:name=>"John")
    end

    it "returns values from arguments" do
      exposures.add(:name, default: 'John')
      locals = exposures.locals(name: 'William')

      expect(locals).to eq(:name=>"William")
    end

    it "returns values from arguments even when value is nil" do
      exposures.add(:name, default: 'John')
      locals = exposures.locals(name: nil)

      expect(locals).to eq(:name=>nil)
    end

    it "returns value from proc" do
      exposures.add(:name, -> name: { name.upcase }, default: 'John')
      locals = exposures.locals(name: 'William')

      expect(locals).to eq(:name=>"WILLIAM")
    end
  end
end
