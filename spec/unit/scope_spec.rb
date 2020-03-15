# frozen_string_literal: true

require "hanami/view/scope_builder"

RSpec.describe Hanami::View::Scope do
  let(:locals) { {} }

  context "with a render environment" do
    subject(:scope) {
      described_class.new(
        locals: locals,
        render_env: render_env
      )
    }

    let(:render_env) { spy(:render_env, format: :xml, context: context) }
    let(:context) { double(:context) }

    describe "#render" do
      it "renders a partial with itself as the scope" do
        scope.render(:info)
        expect(render_env).to have_received(:partial).with(:info, scope)
      end

      it "renders a partial with provided locals" do
        scope_with_locals = described_class.new(
          locals: {foo: "bar"},
          render_env: render_env
        )

        scope.render(:info, foo: "bar")

        expect(render_env).to have_received(:partial).with(:info, scope_with_locals)
      end
    end

    describe "#_format" do
      it "returns the render environments's format" do
        expect(scope._format).to eq :xml
      end
    end

    describe "#_context" do
      it "returns the render environment's context" do
        expect(scope._context).to be context
      end
    end

    describe "#method_missing" do
      describe "matching locals" do
        let(:locals) { {greeting: "hello from locals"} }
        let(:context) { double(:context, greeting: "hello from context") }

        it "returns a matching value from the locals, in favour of a matching method on the context" do
          expect(scope.greeting).to eq "hello from locals"
        end
      end

      describe "matching context" do
        let(:context) { double(:context, greeting: "hello from context") }

        it "calls the matching method on the context" do
          expect(scope.greeting).to eq "hello from context"
        end

        it "forwards all arguments to the method" do
          blk = -> {}
          scope.greeting "args", &blk

          expect(context).to have_received(:greeting).with("args", &blk)
        end
      end

      describe "matching convenience methods" do
        it "provides #context" do
          expect(scope.context).to be context
        end

        it "provides #locals" do
          expect(scope.locals).to be locals
        end
      end

      describe "no matches" do
        it "raises an error" do
          expect { scope.greeting }.to raise_error(NoMethodError)
        end
      end
    end
  end

  context "without a render environment" do
    subject(:scope) {
      described_class.new(locals: locals)
    }

    describe "#render" do
      it "raises an error" do
        expect { scope.render(:info) }.to raise_error(Hanami::View::RenderEnvironmentMissing::MissingEnvironmentError)
      end
    end

    describe "#scope" do
      it "raises an error" do
        expect { scope.scope(:info) }.to raise_error(Hanami::View::RenderEnvironmentMissing::MissingEnvironmentError)
      end
    end

    describe "#_context" do
      it "raises an error" do
        expect { scope._context }.to raise_error(Hanami::View::RenderEnvironmentMissing::MissingEnvironmentError)
      end
    end
  end
end
