# frozen_string_literal: true

require "dry/inflector"
require "hanami/view"
require "pathname"

module TestNamespace
  def remove_constants
    constants.each do |name|
      remove_const(name)
    end
  end
end

RSpec.describe "Hanami application views" do
  subject(:view_class) { Class.new(Hanami::View) }

  context "outside Hanami app" do
    before do
      allow(Hanami).to receive(:respond_to?).with(:application) { nil }
    end

    it "does not apply" do
      expect(view_class.config.paths).to eq []
    end
  end

  context "inside Hanami app" do
    let(:application) {
      double(:application, config: config)
    }

    let(:config) {
      double(
        :config,
        views: double(
          :views_config,
          base_path: "views",
          templates_path: "templates",
          layouts_dir: "layouts",
          default_layout: "my_app",
        )
      )
    }

    let(:slice) {
      double(
        :slice,
        application: application,
        inflector: Dry::Inflector.new,
        namespace_path: "main",
        root: Pathname("/path/to/app/slices/main")
      )
    }

    before do
      allow(Hanami).to receive(:application) { application }
      allow(application).to receive(:component_provider) { slice }

      Object.const_set(:Main, Module.new { |m| m.extend(TestNamespace) })
    end

    after do
      Main.remove_constants
      Object.send :remove_const, :Main
    end

    context "base application view class" do
      let(:view_class) {
        module Main
          class View < Hanami::View
          end
        end

        Main::View
      }

      it "configures the class for its provider" do
        expect(view_class.config.paths).to match [
          an_object_satisfying { |path| path.dir.to_s == "/path/to/app/slices/main/templates" }
        ]
        expect(view_class.config.layouts_dir).to eq "layouts"
        expect(view_class.config.layout).to eq "my_app"
      end

      it "does not configure a template name" do
        expect(view_class.config.template).to be_nil
      end
    end

    context "inheriting from base application view class" do
      let!(:base_view) {
        module Main
          class View < Hanami::View
          end
        end
      }

      let(:view_class) {
        module Main
          module Views
            module Articles
              class Index < View
              end
            end
          end
        end

        Main::Views::Articles::Index
      }

      it "inherits the base view's configuration" do
        expect(view_class.config.paths).to match [
          an_object_satisfying { |path| path.dir.to_s == "/path/to/app/slices/main/templates" }
        ]
        expect(view_class.config.layouts_dir).to eq "layouts"
        expect(view_class.config.layout).to eq "my_app"
      end

      it "configures a template name for the inheriting view" do
        expect(view_class.config.template).to eq "articles/index"
      end

      it "applies the application view behavior only once" do
        expect(view_class.ancestors.select { |mod|
          mod.kind_of?(Hanami::View::ApplicationView)
        }.length).to eq 1
      end
    end
  end
end
