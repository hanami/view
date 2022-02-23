# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application view / Template", :application_integration do
  subject(:template) { view_class.config.template }

  before do
    module TestApp
      class Application < Hanami::Application
      end
    end

    module Main
    end

    Hanami.application.instance_eval(&application_hook) if respond_to?(:application_hook)

    Hanami.application.register_slice :main, namespace: Main, root: "/path/to/app/slices/main"

    Hanami.prepare

    module TestApp
      module View
        class Base < Hanami::View
        end
      end
    end

    module Main
      module View
        class Base < TestApp::View::Base
        end
      end
    end
  end

  context "Application base view" do
    let(:view_class) { TestApp::View::Base }

    it "configures the template to match the class name" do
      expect(template).to eq "view/base"
    end
  end

  context "Slice base view" do
    let(:view_class) { Main::View::Base }

    it "configures the template to match the class name" do
      expect(template).to eq "main/view/base"
    end
  end

  context "Slice view" do
    let(:view_class) {
      module Main
        module Views
          module Article
            class Index < View::Base
            end
          end
        end
      end

      Main::Views::Article::Index
    }

    it "configures the tempalte to match the class name" do
      expect(template).to eq "article/index"
    end
  end

  context "Slice view with namespace matching template inference base" do
    let(:application_hook) {
      proc do
        config.views.template_inference_base = "my_views"
      end
    }

    let(:view_class) {
      module Main
        module MyViews
          module Users
            class Show < View::Base
            end
          end
        end
      end

      Main::MyViews::Users::Show
    }

    it "configures the tempalte to match the class name" do
      expect(template).to eq "users/show"
    end
  end
end
