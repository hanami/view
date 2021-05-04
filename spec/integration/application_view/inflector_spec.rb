# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application view / Inflector", :application_integration do
  before do
    module TestApp
      class Application < Hanami::Application
        config.autoloader = nil
      end
    end

    TestApp::Application.instance_eval(&application_class_config)

    module Main
    end

    Hanami.application.register_slice :main, namespace: Main, root: "/path/to/app/slices/main"
    Hanami.init
  end

  let(:application_class_config) { proc {} }

  subject(:view_class) {
    module Main
      class View < Hanami::View
      end
    end

    Main::View
  }

  context "no application inflector configured" do
    it "configures the view with the default application inflector" do
      expect(view_class.config.inflector).to be TestApp::Application.config.inflector
    end
  end

  context "custom inflections configured" do
    let(:application_class_config) {
      proc do
        config.inflector do |inflections|
          inflections.acronym "NBA"
        end
      end
    }

    it "configures the view with the customized application inflector" do
      expect(view_class.config.inflector).to be TestApp::Application.config.inflector
      expect(view_class.config.inflector.camelize("nba_jam")).to eq "NBAJam"
    end
  end

  context "custom inflector configured on view class" do
    let(:custom_inflector) { Object.new }

    before do
      view_class.config.inflector = custom_inflector
    end

    it "overrides the default application inflector" do
      expect(view_class.config.inflector).to be custom_inflector
    end
  end
end
