RSpec.describe Dry::View::Exposure do
  subject(:exposure) { described_class.new(:hello, proc) }

  let(:proc) { -> input { "hi" } }

  describe "initialization and attributes" do
    describe "#name" do
      it "accepts a name" do
        expect(exposure.name).to eql :hello
      end
    end

    describe "#proc" do
      it "accepts a proc" do
        expect(exposure.proc).to eql proc
      end

      it "allows a nil proc" do
        expect(described_class.new(:hello).proc).to be_nil
      end

      it "allows proc to take no arguments" do
        proc = -> { "hi" }
        expect { described_class.new(:hello, proc) }.not_to raise_error
      end

      it "requires proc to take positional arguments only" do
        proc = -> a: "a" { "hi" }
        expect { described_class.new(:hello, proc) }.to raise_error ArgumentError

        proc = -> input, a: "a" { "hi" }
        expect { described_class.new(:hello, proc) }.to raise_error ArgumentError
      end
    end

    describe "#to_view" do
      it "is true by default" do
        expect(exposure.to_view).to be true
      end

      it "can be set to false on initialization" do
        expect(described_class.new(:hello, to_view: false).to_view).to be false
      end
    end
  end

  describe "#bind" do
    context "proc provided" do
      subject(:bound_exposure) { exposure.bind(Object.new) }

      it "returns itself" do
        expect(bound_exposure).to eql exposure
      end

      it "retains the same proc" do
        expect(bound_exposure.proc).to eql proc
      end
    end

    context "no proc provided" do
      subject(:bound_exposure) { exposure.bind(object) }

      let(:exposure) { described_class.new(:hello) }

      let(:object) do
        Class.new do
          def hello(input)
            "hi there, #{input.fetch(:name)}"
          end
        end.new
      end

      it "returns a new object" do
        expect(bound_exposure).not_to eql exposure
      end

      it "sets the proc to the method on the object matching the exposure's name" do
        expect(bound_exposure.proc).to eql object.method(:hello)
      end

      it "raises an error if the object has no matching method" do
        expect { described_class.new(:something_else).bind(object) }.to raise_error NameError
      end
    end
  end

  describe "#dependencies" do
    let(:proc) { -> input, foo, bar { "hi" } }

    it "returns an array of exposure dependencies derived from the proc's argument names" do
      expect(exposure.dependencies).to eql [:input, :foo, :bar]
    end
  end

  describe "#call" do
    let(:input) { double("input") }

    before do
      allow(proc).to receive(:call)
    end

    context "proc expects input only" do
      it "sends the input to the proc" do
        exposure.(input)

        expect(proc).to have_received(:call).with(input)
      end
    end

    context "proc expects input and dependencies" do
      let(:proc) { -> input, greeting { "#{greeting}, #{input.fetch(:name)}" } }
      let(:locals) { {greeting: "Hola"} }

      before do
        exposure.(input, locals)
      end

      it "sends the input and dependency values to the proc" do
        expect(proc).to have_received(:call).with(input, "Hola")
      end
    end

    context "proc expects dependencies only" do
      let(:proc) { -> greeting, farewell { "#{greeting}, #{input.fetch(:name)}" } }
      let(:locals) { {greeting: "Hola", farewell: "Adios"} }

      before do
        exposure.(input, locals)
      end

      it "sends the dependency values to the proc" do
        expect(proc).to have_received(:call).with "Hola", "Adios"
      end
    end
  end
end
