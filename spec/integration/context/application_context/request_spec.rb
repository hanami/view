require "hanami"
require "hanami/view/application_context"

RSpec.describe "Application context / Request", :application_integration do
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
        class Context < Hanami::View::ApplicationContext
        end
      end
    end
    TestApp::View::Context
  }

  subject(:context) {
    context_class.new(
      request: request,
      response: response,
    )
  }

  let(:request) { double(:request) }
  let(:response) { double(:response) }

  describe "#request" do
    it "is the provided request" do
      expect(context.request).to be request
    end
  end

  describe "#sesion" do
    let(:session) { double(:session) }

    before do
      allow(request).to receive(:session) { session }
    end

    it "is the request's session" do
      expect(context.session).to be session
    end
  end

  describe "#flash" do
    let(:flash) { double(:flash) }

    before do
      allow(response).to receive(:flash) { flash }
    end

    it "is the response's flash" do
      expect(context.flash).to be flash
    end
  end
end
