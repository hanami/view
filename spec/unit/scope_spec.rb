require 'dry/view/scope'

RSpec.describe Dry::View::Scope do
  subject(:scope) do
    described_class.new(renderer, data)
  end

  let(:renderer) { double("renderer") }
  let(:data) { {user_name: "Jane Doe"} }

  # describe '#render' do
  #   it "renders with the current data if no arguments passed" do
  #     scope.render

  #   end

  #   it "renders with a new scope using the arguments passed"
  #   it "raises an error if a non-Hash is passed as the argument"
  # end

  describe "missing method behavior" do
    describe "rendering" do
      before do
        allow(renderer).to receive(:lookup).with('_list').and_return '_list.html.slim'
        allow(renderer).to receive(:lookup).with('_user_name').and_return '_user_name.html.slim'
        allow(renderer).to receive(:render)
      end

      it "renders a matching partial using the existing scope" do
        scope.list

        expect(renderer).to have_received(:render).with('_list.html.slim', scope)
      end

      it "renders a matching partial using a scope based on arguments passed" do
        scope.list(something: 'else')

        expect(renderer).to have_received(:render)
          .with('_list.html.slim', described_class.new(renderer, something: 'else'))
      end

      it "renders a partial in favour of a matching data value" do
        scope.user_name

        expect(renderer).to have_received(:render).with('_user_name.html.slim', scope)
      end

      it "raises an error if arguments passed are not a hash" do
        expect { scope.list('hi') }.to raise_error(ArgumentError)
      end
    end

    describe "accessing scope data" do
      before do
        allow(renderer).to receive(:lookup).and_return false
      end

      it "returns matching scope data" do
        expect(scope.user_name).to eq "Jane Doe"
      end

      it "raises an error when no data matches" do
        expect { scope.missing }.to raise_error(NoMethodError)
      end
    end
  end
end
