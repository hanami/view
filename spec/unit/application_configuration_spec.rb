require "hanami/view/application_configuration"
require "saharspec/matchers/dont"

RSpec.describe Hanami::View::ApplicationConfiguration do
  subject(:configuration) { described_class.new }

  it "includes base view configuration" do
    expect(configuration).to respond_to(:paths)
    expect(configuration).to respond_to(:paths=)
  end

  it "is does not include the inflector setting" do
    expect(configuration).not_to respond_to(:inflector)
    expect(configuration).not_to respond_to(:inflector=)
  end

  it "preserves default values from the base view configuration" do
    expect(configuration.layouts_dir).to eq Hanami::View.config.layouts_dir
  end

  it "allows settings to be configured independently of the base view configuration" do
    expect { configuration.layouts_dir = "custom_layouts" }
      .to change { configuration.layouts_dir }.to("custom_layouts")
      .and dont.change { Hanami::View.config.layouts_dir }
  end

  describe "specialised default values" do
    describe "paths" do
      it 'is ["web/templates"]' do
        expect(configuration.paths).to match [
          an_object_satisfying { |path| path.dir.to_s == "web/templates" }
        ]
      end
    end

    describe "template_inference_base" do
      it 'is "views"' do
        expect(configuration.template_inference_base).to eq "views"
      end
    end

    describe "layout" do
      it 'is "application"' do
        expect(configuration.layout).to eq "application"
      end
    end
  end

  describe "#settings" do
    it "includes all view settings apart from inflector" do
      expect(configuration.settings).to eq Hanami::View.settings - [:inflector]
    end
  end
end
