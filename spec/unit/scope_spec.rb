require 'dry/view/scope'

RSpec.describe Dry::View::Scope do
  subject(:scope) {
    described_class.new(renderer, data, context)
  }

  let(:renderer) { double("renderer") }
  let(:data) { {user_name: "Jane Doe"} }
  let(:context) {
    Class.new do
      def asset(name)
        "#{name}.jpg"
      end

      def current_user
        "current user"
      end
    end.new
  }

  describe "missing method behavior" do
    before do
      allow(renderer).to receive(:lookup).and_return false
    end

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

    describe "accessing data" do
      let(:data) { {user_name: "Jane Doe", current_user: "provided by data"} }

      it "returns matching scope data" do
        expect(scope.user_name).to eq "Jane Doe"
      end

      it "raises an error when no data matches" do
        expect { scope.missing }.to raise_error(NoMethodError)
      end

      it "returns data in favour of context methods" do
        expect(scope.current_user).to eq "provided by data"
      end
    end

    describe "accessing context" do
      it "forwards to matching methods on the context" do
        expect(scope.current_user).to eq "current user"
        expect(scope.asset("mindblown")).to eq "mindblown.jpg"
      end
    end
  end
end
