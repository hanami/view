require 'test_helper'

describe 'Template name' do
  before do
    # # #
    #
    # Standalone usage:
    #
    #
    Display = Class.new { include Lotus::View }

    # # #
    #
    # Top level application:
    #
    #
    # app/
    #   controllers/
    #     hardware_controller.rb      HardwareController::Display
    #     software_controller.rb      SoftwareController::Display
    #   templates/
    #     hardware/
    #       display.html.erb
    #     software/
    #       display.html.erb
    #   views/
    #     hardware/
    #       display.rb          HardwareView::Display
    #     software/
    #       display.rb          SoftwareView::Display
    # application.rb
    #
    #     module InformationTech
    #       class Application < Lotus::Application
    #       end
    #     end
    #
    #     Lotus::View.configure do
    #       root 'app/templates'
    #     end
    #
    #     class HardwareController
    #       include Lotus::Controller
    #
    #       action 'Display' do
    #         def call(params)
    #         end
    #       end
    #     end
    #
    #     class SoftwareController
    #       include Lotus::Controller
    #
    #       action 'Display' do
    #         def call(params)
    #         end
    #       end
    #     end
    module HardwareView
      Display = Class.new { include Lotus::View }
    end

    # # #
    #
    # Modulized application:
    #
    #
    # app/
    #   controllers/
    #     furnitures/
    #       catalog_controller.rb        Furnitures::CatalogController::Index
    #       furnitures_controller.rb     Furnitures::FurnituresController::Index
    #   templates/
    #     furnitures/
    #       standalone.html.erb
    #       catalog/
    #         index.html.erb
    #       furnitures/
    #         index.html.erb
    #   views/
    #     furnitures/
    #       standalone.rb                Furnitures::Standalone
    #       catalog/
    #         index.rb                   Furnitures::Catalog::Index
    #       furnitures/
    #         index.rb                   Furnitures::Furnitures::Index
    # application.rb                     Furnitures::Application
    module Furnitures
      View = Lotus::View.duplicate(self) do
        # This line is here only for ducumentation purposes, but it's commented
        # because the path doesn't exist.
        #
        # root 'app/templates/furnitures'
      end

      class Standalone
        include Furnitures::View
      end

      module Catalog
        class Index
          include Furnitures::View
        end
      end

      module Furnitures
        class Index
          include ::Furnitures::View
        end
      end
    end

    # # #
    #
    # Microservice application
    #
    #
    # apps/
    #   frontend/
    #     application.rb                 Frontend::Application
    #     controllers/
    #       sessions.rb                  Frontend::Controllers::Sessions::New
    #     templates/
    #       standalone_view.html.erb
    #       standalone.html.erb
    #       sessions/
    #         new.html.erb
    #     views/
    #       standalone_view.rb           Frontend::StandaloneView
    #       standalone.rb                Frontend::Views::Standalone
    #       sessions/
    #         new.rb                     Frontend::Views::Sessions::New
    #   backend/
    #     application.rb                 Backend::Application
    module Frontend
      View = Lotus::View.duplicate(self) do
        # This line is here only for ducumentation purposes, but it's commented
        # because the path doesn't exist.
        #
        # root 'apps/frontend/templates'
      end

      class StandaloneView
        include Frontend::View
      end

      module Views
        class Standalone
          include Frontend::View
        end

        module Sessions
          class New
            include Frontend::View
          end
        end
      end
    end

    # # #
    #
    # Microservice application
    #
    #
    # apps/
    #   web/
    #     controllers/
    #       books.rb              Bookshelf::Web::Controllers::Books::Show
    #     views/
    #       books/
    #         show.rb             Bookshelf::Web::Views::Books::Show
    #     templates/
    #       books/
    #         show.html.erb
    #     application.rb          Bookshelf::Web
    #   api/
    #     controllers/
    #       books.rb              Bookshelf::Api::Controllers::Books::Show
    #     views/
    #       books/
    #         show.rb             Bookshelf::Api::Views::Books::Show
    #     templates/
    #       books/
    #         show.html.erb
    #     application.rb          Bookshelf::Api
    module Bookshelf
      module Web
        View = Lotus::View.duplicate(self) do
          # This line is here only for ducumentation purposes, but it's
          # commented because the path doesn't exist.
          #
          # root 'apps/web/templates'
        end

        module Views
          module Books
            class Show
              include Bookshelf::Web::View
            end
          end
        end
      end

      module Api
        View = Lotus::View.duplicate(self) do
          # This line is here only for ducumentation purposes, but it's
          # commented because the path doesn't exist.
          #
          # root 'apps/api/templates'
        end

        module Views
          module Books
            class Show
              include Bookshelf::Api::View
            end
          end
        end
      end
    end
  end

  after do
    Object.send(:remove_const, :Display)
    Object.send(:remove_const, :HardwareView)
    Object.send(:remove_const, :Furnitures)
    Object.send(:remove_const, :Frontend)
    Object.send(:remove_const, :Bookshelf)
  end

  #
  # Standalone application
  #
  it 'uses class name to compose it' do
    Display.template.must_equal 'display'
  end

  it 'include modules' do
    HardwareView::Display.template.must_equal 'hardware_view/display'
  end

  #
  # Modulized application
  #
  it 'ignores configured namespace' do
    Furnitures::Standalone.template.must_equal     'standalone'
    Furnitures::Catalog::Index.template.must_equal 'catalog/index'
  end

  it 'allows to use a name equal to the namespace' do
    Furnitures::Furnitures::Index.template.must_equal 'furnitures/index'
  end

  #
  # Microservice application
  #
  it 'ignores nested namespace' do
    Frontend::StandaloneView.template.must_equal       'standalone_view'
    Frontend::Views::Standalone.template.must_equal    'standalone'
    Frontend::Views::Sessions::New.template.must_equal 'sessions/new'
  end

  it 'ignores deeply nested namespace' do
    Bookshelf::Web::Views::Books::Show.template.must_equal 'books/show'
    Bookshelf::Api::Views::Books::Show.template.must_equal 'books/show'
  end
end
