# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application view / Inflector", :application_integration do
  before do
    module TestApp
      class Application < Hanami::Application
      end
    end

    Hanami.application.instance_eval(&application_class_config)
    Hanami.application.register_slice :main
    Hanami.application.prepare

    module TestApp
      module View
        class Base < Hanami::View
        end
      end
    end
  end

  let(:application_class_config) { proc {} }

  subject(:view_class) {
    module Main
      module View
        class Base < TestApp::View::Base
        end
      end
    end

    Main::View::Base
  }

  context "no application inflector configured" do
    it "configures the view with the default application inflector" do
      expect(view_class.config.inflector).to be TestApp::Application.config.inflector
    end
  end

  context "custom inflections configured" do
    let(:application_class_config) {
      proc do
        config.inflections do |inflections|
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
