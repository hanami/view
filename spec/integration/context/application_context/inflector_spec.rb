require "hanami"
require "hanami/view/context"

RSpec.describe "Application context / Inflector", :application_integration do
  before do
    module TestApp
      class Application < Hanami::Application
      end
    end

    Hanami.init
  end

  let(:context_class) {
    module TestApp
      module View
        class Context < Hanami::View::Context
        end
      end
    end
    TestApp::View::Context
  }

  subject(:context) {
    context_class.new
  }

  describe "#inflector" do
    it "is the application inflector by default" do
      expect(context.inflector).to be TestApp::Application.inflector
    end

    context "injected inflector" do
      subject(:context) {
        context_class.new(inflector: inflector)
      }

      let(:inflector) { double(:inflector) }

      it "is the injected inflector" do
        expect(context.inflector).to be inflector
      end

      context "rebuilt context" do
        subject(:new_context) { context.with }

        it "retains the injected inflector" do
          expect(new_context.inflector).to be inflector
        end
      end
    end
  end
end
