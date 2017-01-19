require 'dry/view/scope'

RSpec.describe Dry::View::Scope do
  subject(:scope) {
    described_class.new(renderer, data, context)
  }

  let(:renderer) { double("renderer") }
  let(:data) { {} }
  let(:context) { Object.new }

  describe "missing method behavior" do
    before do
      allow(renderer).to receive(:lookup).and_return false
      allow(renderer).to receive(:render)
    end

    describe "accessing data" do
      let(:data) { {user_name: "Jane Doe", current_user: "data's current_user"} }
      let(:context) {
        Class.new do
          def current_user
            "context's current_user"
          end
        end.new
      }

      before do
        allow(renderer).to receive(:lookup).with('_current_user').and_return '_current_user.html.slim'
      end

      it "returns matching scope data" do
        expect(scope.user_name).to eq "Jane Doe"
      end

      it "raises an error when no data matches" do
        expect { scope.missing }.to raise_error(NoMethodError)
      end

      it "returns data in favour of both context methods and partials" do
        expect(scope.current_user).to eq "data's current_user"
      end
    end

    describe "accessing context" do
      let(:context) {
        Class.new do
          def current_user
            "context's current_user"
          end

          def asset(name)
            "#{name}.jpg"
          end
        end.new
      }

      before do
        allow(renderer).to receive(:lookup).with('_current_user').and_return '_current_user.html.slim'
      end

      it "forwards to matching methods on the context in favour of partials" do
        expect(scope.current_user).to eq "context's current_user"
      end

      it "allows arguments to be passed to those methods as normal" do
        expect(scope.asset("mindblown")).to eq "mindblown.jpg"
      end

      it "raises an error when no method matches" do
        expect { scope.missing }.to raise_error(NoMethodError)
      end
    end

    describe "rendering" do
      before do
        allow(renderer).to receive(:lookup).with('_list').and_return '_list.html.slim'
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

      it "raises an error if arguments passed are not a hash" do
        expect { scope.list('hi') }.to raise_error(ArgumentError)
      end
    end
  end
end
