require "hanami"
require "hanami/view/context"

RSpec.describe "Application context / Activation", :application_integration do
  context "Inside Hanami app" do
    before do
      module TestApp
        class Application < Hanami::Application
        end
      end

      Hanami.init
    end

    subject(:context_class) {
      module TestApp
        module View
          class Context < Hanami::View::Context
          end
        end
      end
      TestApp::View::Context
    }

    it "is an ApplicationContext" do
      expect(context_class.ancestors).to include Hanami::View::ApplicationContext
    end
  end

  context "Outside Hanami app" do
    subject(:context_class) {
      Class.new(Hanami::View::Context)
    }

    it "is not an ApplicationContext" do
      expect(context_class.ancestors).not_to include Hanami::View::ApplicationContext
    end
  end
end
