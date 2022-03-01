# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application view / Part namespace", :application_integration do
  subject(:part_namespace) { view_class.config.part_namespace }

  before do
    module TestApp
      class Application < Hanami::Application
      end
    end

    Hanami.application.instance_eval(&application_hook) if respond_to?(:application_hook)
    Hanami.application.register_slice :main
    Hanami.application.prepare
  end

  context "view in slice" do
    let(:view_class) {
      module TestApp
        module View
          class Base < Hanami::View; end
        end
      end

      module Main
        module View
          class Base < TestApp::View::Base
          end
        end
      end

      Main::View::Base
    }

    context "parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = "view/custom_parts"
        end
      }

      context "namespace exists" do
        before do
          module Main
            module View
              module CustomParts
              end
            end
          end
        end

        it "is the matching module within the slice" do
          is_expected.to eq Main::View::CustomParts
        end
      end

      context "namespace exists, but needs requiring" do
        before do
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("main/view/custom_parts") {
            module Main
              module View
                module CustomParts
                end
              end
            end

            true
          }
        end

        it "is the matching module within the slice" do
          is_expected.to eq Main::View::CustomParts
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
        module View
          class Base < Hanami::View; end
        end
      end

      TestApp::View::Base
    }

    context "parts_path configured" do
      let(:application_hook) {
        proc do
          config.views.parts_path = "view/custom_parts"
        end
      }

      context "namespace exists" do
        before do
          module TestApp
            module View
              module CustomParts
              end
            end
          end
        end

        it "is the matching module within the slice" do
          is_expected.to eq TestApp::View::CustomParts
        end
      end

      context "namespace exists, but needs requiring" do
        before do
          allow_any_instance_of(Object).to receive(:require).and_call_original
          allow_any_instance_of(Object).to receive(:require).with("test_app/view/custom_parts") {
            module TestApp
              module View
                module CustomParts
                end
              end
            end

            true
          }
        end

        it "is the matching module within the slice" do
          is_expected.to eq TestApp::View::CustomParts
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
