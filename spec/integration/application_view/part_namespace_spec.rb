# frozen_string_literal: true

require "hanami"
require "hanami/view/application_view"

RSpec.describe "Application view / Part namespace", :application_integration do
  subject(:template) { view_class.config.part_namespace }

  before do
    module TestApp
      class Application < Hanami::Application
      end
    end

    Hanami.application.instance_eval(&application_hook) if respond_to?(:application_hook)

    module Main
    end

    Hanami.application.register_slice :main, namespace: Main, root: "/path/to/app/slices/main"

    Hanami.init
  end

  context "view in slice" do
    let(:view_class) {
      module Main
        class View < Hanami::View::ApplicationView
        end
      end

      Main::View
    }

    context "parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = "views/custom_parts"
        end
      }

      context "namespace exists" do
        before do
          module Main
            module Views
              module CustomParts
              end
            end
          end
        end

        it "is the matching module within the slice" do
          is_expected.to eq Main::Views::CustomParts
        end
      end

      context "namespace exists, but needs requiring" do
        before do
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("main/views/custom_parts") {
            module Main
              module Views
                module CustomParts
                end
              end
            end

            true
          }
        end

        it "is the matching module within the slice" do
          is_expected.to eq Main::Views::CustomParts
        end
      end

      context "namespace does not exist" do
        it "is nil" do
          is_expected.to be_nil
        end
      end
    end

    context "nil parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = nil
        end
      }

      it "is nil" do
        is_expected.to be_nil
      end
    end
  end

  context "view in application" do
    let(:view_class) {
      module TestApp
        class View < Hanami::View::ApplicationView
        end
      end

      TestApp::View
    }

    context "parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = "views/custom_parts"
        end
      }

      context "namespace exists" do
        before do
          module TestApp
            module Views
              module CustomParts
              end
            end
          end
        end

        it "is the matching module within the slice" do
          is_expected.to eq TestApp::Views::CustomParts
        end
      end

      context "namespace exists, but needs requiring" do
        before do
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("test_app/views/custom_parts") {
            module TestApp
              module Views
                module CustomParts
                end
              end
            end

            true
          }
        end

        it "is the matching module within the slice" do
          is_expected.to eq TestApp::Views::CustomParts
        end
      end

      context "namespace does not exist" do
        it "is nil" do
          is_expected.to be_nil
        end
      end
    end

    context "nil parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = nil
        end
      }

      it "is nil" do
        is_expected.to be_nil
      end
    end
  end
end
