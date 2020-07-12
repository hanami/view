# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application views" do
  context "Outside Hanami app" do
    subject(:view_class) { Class.new(Hanami::View) }

    before do
      allow(Hanami).to receive(:respond_to?).with(:application?) { nil }
    end

    it "is not an application view" do
      expect(view_class.ancestors).not_to include(a_kind_of(Hanami::View::ApplicationView))
    end

    it "does not configure the view" do
      expect(view_class.config.paths).to eq []
    end
  end

  context "Inside Hanami app", :application_integration do
    before do
      module TestApp
        class Application < Hanami::Application
          config.root = "/path/to/app"
          config.views.template_inference_base = "views"
          config.views.paths = ["templates"]
          config.views.layouts_dir = "test_app_layouts"
          config.views.layout = "testing"
        end
      end
    end

    context "Base view defined inside slice" do
      before do
        module Main
        end

        Hanami.application.register_slice :main, namespace: Main, root: "/path/to/app/slices/main"
        Hanami.init
      end

      let(:base_view_class) {
        module Main
          class View < Hanami::View
          end
        end

        Main::View
      }

      describe "base view class" do
        subject(:view_class) { base_view_class }

        it "is an application view" do
          expect(view_class.ancestors).to include(a_kind_of(Hanami::View::ApplicationView))
        end

        describe "config" do
          subject(:config) { view_class.config }

          describe "path" do
            context "relative path provided in application config" do
              before do
                Hanami.application.config.views.paths = ["templates"]
              end

              it "configures the path as the relative path appended onto the slice's root path" do
                expect(config.paths.map { |path| path.dir.to_s }).to eq ["/path/to/app/slices/main/templates"]
              end
            end

            context "absolute path provided in application config" do
              before do
                Hanami.application.config.views.paths = ["/absolute/path"]
              end

              it "leaves the absolute path in place" do
                expect(config.paths.map { |path| path.dir.to_s }).to eq ["/absolute/path"]
              end
            end
          end

          it "applies standard view configuration from the application" do
            aggregate_failures do
              expect(config.layouts_dir).to eq "test_app_layouts"
              expect(config.layout).to eq "testing"
            end
          end

          it "does not configure the template" do
            expect(view_class.config.template).to be_nil
          end
        end
      end

      describe "subclass of base view class" do
        subject(:view_class) {
          base_view_class

          module Main
            module Views
              module Articles
                class Index < Main::View
                end
              end
            end
          end

          Main::Views::Articles::Index
        }

        it "inherits the application-specific configuration from the base class" do
          config = view_class.config

          aggregate_failures do
            expect(config.paths.map { |path| path.dir.to_s }).to eq ["/path/to/app/slices/main/templates"]
            expect(config.layouts_dir).to eq "test_app_layouts"
            expect(config.layout).to eq "testing"
          end
        end

        it "configures the template name based on the view's class name, relative to the slice and configured views base_path" do
          expect(view_class.config.template).to eq "articles/index"
        end
      end
    end

    context "Base view defined directly inside application" do
      before do
        Hanami.init
      end

      let(:base_view_class) {
        module TestApp
          class View < Hanami::View
          end
        end

        TestApp::View
      }

      describe "base view class" do
        subject(:view_class) { base_view_class }

        it "is an application view" do
          expect(view_class.ancestors).to include(a_kind_of(Hanami::View::ApplicationView))
        end

        describe "config" do
          subject(:config) { view_class.config }

          describe "path" do
            context "relative path provided in application config" do
              before do
                Hanami.application.config.views.paths = ["templates"]
              end

              it "configures the path as the relative path appended onto the slice's root path" do
                expect(config.paths.map { |path| path.dir.to_s }).to eq ["/path/to/app/templates"]
              end
            end

            context "absolute path provided in application config" do
              before do
                Hanami.application.config.views.paths = ["/absolute/path"]
              end

              it "leaves the absolute path in place" do
                expect(config.paths.map { |path| path.dir.to_s }).to eq ["/absolute/path"]
              end
            end
          end
        end

        it "does not configure the template" do
          expect(view_class.config.template).to be_nil
        end
      end

      describe "subclass of base view class" do
        subject(:view_class) {
          base_view_class

          module TestApp
            module Views
              module Articles
                class Index < TestApp::View
                end
              end
            end
          end

          TestApp::Views::Articles::Index
        }

        it "inherits the application-specific configuration from the base class" do
          config = view_class.config

          aggregate_failures do
            expect(config.paths.map { |path| path.dir.to_s }).to eq ["/path/to/app/templates"]
            expect(config.layouts_dir).to eq "test_app_layouts"
            expect(config.layout).to eq "testing"
          end
        end

        it "configures the template name based on the view's class name, relative to the slice and configured views base_path" do
          expect(view_class.config.template).to eq "articles/index"
        end
      end
    end
  end
end
