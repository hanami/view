# frozen_string_literal: true

require "hanami"
require "hanami/view"

RSpec.describe "Application view / Template", :application_integration do
  subject(:template) { view_class.config.template }

  before do
    module TestApp
      class Application < Hanami::Application
        config.autoloader = nil
      end
    end

    module Main
    end

    Hanami.application.instance_eval(&application_hook) if respond_to?(:application_hook)

    Hanami.application.register_slice :main, namespace: Main, root: "/path/to/app/slices/main"

    Hanami.init
  end

  context "Direct Hanami::View subclass" do
    let(:view_class) {
      module Main
        class View < Hanami::View
        end
      end

      Main::View
    }

    it "configures the template to match the class name" do
      expect(template).to eq "view"
    end
  end

  context "Deeper Hanami::View subclass" do
    let(:view_class) {
      module Main
        class View < Hanami::View
        end

        class ArticleIndex < View
        end
      end

      Main::ArticleIndex
    }

    it "configures the tempalte to match the class name" do
      expect(template).to eq "article_index"
    end
  end

  context "Deeper Hanami::View subclass, namespace matching template inference base" do
    let(:application_hook) {
      proc do
        config.views.template_inference_base = "my_views"
      end
    }

    let(:view_class) {
      module Main
        class View < Hanami::View
        end

        module MyViews
          module Articles
            class Index < View
            end
          end
        end
      end

      Main::MyViews::Articles::Index
    }

    it "configures the tempalte to match the class name" do
      expect(template).to eq "articles/index"
    end
  end
end
