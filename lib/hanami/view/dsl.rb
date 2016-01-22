require 'hanami/view/rendering/template_name'
require 'hanami/view/rendering/layout_finder'

module Hanami
  module View
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      # When a value is given, specify a templates root path for the view.
      # Otherwise, it returns templates root path.
      #
      # When not initialized, it will return the global value from `Hanami::View.root`.
      #
      # @param value [String] the templates root for this view
      #
      # @return [Pathname] the specified root for this view or the global value
      #
      # @since 0.1.0
      #
      # @example Default usage
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #     end
      #   end
      #
      #   Hanami::View.configuration.root # => 'app/templates'
      #   Articles::Show.root            # => 'app/templates'
      #
      # @example Custom root
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       root 'path/to/articles/templates'
      #     end
      #   end
      #
      #   Hanami::View.configuration.root # => 'app/templates'
      #   Articles::Show.root            # => 'path/to/articles/templates'
      def root(value = nil)
        if value.nil?
          configuration.root
        else
          configuration.root(value)
        end
      end

      # When a value is given, specify the handled format.
      # Otherwise, it returns the previously specified format.
      #
      # @param value [Symbol] the format
      #
      # @return [Symbol, nil] the specified format for this view, if set
      #
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.format     # => nil
      #   Articles::JsonShow.format # => :json
      def format(value = nil)
        if value.nil?
          @format
        else
          @format = value
        end
      end

      # When a value is given, specify the relative path to the template.
      # Otherwise, it returns the name that follows Hanami::View conventions.
      #
      # @param value [String] relative template path
      #
      # @return [String] the specified template for this view or the name
      #   that follows the convention
      #
      # @since 0.1.0
      #
      # @example Default usage
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.template     # => 'articles/show'
      #   Articles::JsonShow.template # => 'articles/show'
      #
      # @example Custom template
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       template 'articles/single_article'
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.template     # => 'articles/single_article'
      #   Articles::JsonShow.template # => 'articles/single_article'
      #
      # @example With namespace
      #   require 'hanami/view'
      #
      #   module Furnitures
      #     View = Hanami::View.generate(self)
      #
      #     class Standalone
      #       include Furnitures::View
      #     end
      #
      #     module Catalog
      #       class Index
      #         Furnitures::View
      #       end
      #     end
      #   end
      #
      #   Furnitures::Standalone.template     # => 'standalone'
      #   Furnitures::Catalog::Index.template # => 'catalog/index'
      #
      # @example With nested namespace
      #   require 'hanami/view'
      #
      #   module Frontend
      #     View = Hanami::View.generate(self)
      #
      #     class StandaloneView
      #       include Frontend::View
      #     end
      #
      #     module Views
      #       class Standalone
      #         include Frontend::View
      #       end
      #
      #       module Sessions
      #         class New
      #           include Frontend::View
      #         end
      #       end
      #     end
      #   end
      #
      #   Frontend::StandaloneView.template       # => 'standalone_view'
      #   Frontend::Views::Standalone.template    # => 'standalone'
      #   Frontend::Views::Sessions::New.template # => 'sessions/new'
      #
      # @example With deeply nested namespace
      #   require 'hanami/view'
      #
      #   module Bookshelf
      #     module Web
      #       View = Hanami::View.generate(self)
      #
      #       module Views
      #         module Books
      #           class Show
      #             include Bookshelf::Web::View
      #           end
      #         end
      #       end
      #     end
      #
      #     module Api
      #       View = Hanami::View.generate(self)
      #
      #       module Views
      #         module Books
      #           class Show
      #             include Bookshelf::Api::View
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      #   Bookshelf::Web::Views::Books::Index.template # => 'books/index'
      #   Bookshelf::Api::Views::Books::Index.template # => 'books/index'
      def template(value = nil)
        if value.nil?
          @template ||= Rendering::TemplateName.new(name, configuration.namespace).to_s
        else
          @template = value
        end
      end

      # When a value is given, it specifies the layout.
      # When false is given, Hanami::View::Rendering::NullLayout is returned.
      # Otherwise, it returns the previously specified layout.
      #
      # When the global configuration is set (`Hanami::View.layout=`), after the
      # loading process, it will return that layout if not otherwise specified.
      #
      # @param value [Symbol, FalseClass, nil] the layout name
      #
      # @return [Symbol, nil] the specified layout for this view, if set
      #
      # @since 0.1.0
      #
      # @see Hanami::Layout
      #
      # @example Default usage
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #     end
      #   end
      #
      #   Articles::Show.layout # => nil
      #
      # @example Custom layout
      #   require 'hanami/view'
      #
      #   class ArticlesLayout
      #     include Hanami::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       layout :articles
      #     end
      #   end
      #
      #   Articles::Show.layout # => :articles
      #
      # @example Global configuration
      #   require 'hanami/view'
      #
      #   class ApplicationLayout
      #     include Hanami::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #     end
      #   end
      #
      #   Hanami::View.layout = :application
      #   Articles::Show.layout # => nil
      #
      #   Hanami::View.load!
      #   Articles::Show.layout # => :application
      #
      # @example Global configuration with custom layout
      #   require 'hanami/view'
      #
      #   class ApplicationLayout
      #     include Hanami::Layout
      #   end
      #
      #   class ArticlesLayout
      #     include Hanami::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       layout :articles
      #     end
      #   end
      #
      #   Hanami::View.layout = :application
      #   Articles::Show.layout # => :articles
      #
      #   Hanami::View.load!
      #   Articles::Show.layout # => :articles
      #
      # @example Disable layout for the view
      #   require 'hanami/view'
      #
      #   class ApplicationLayout
      #     include Hanami::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       layout false
      #     end
      #   end
      #
      #   Hanami::View.load!
      #   Articles::Show.layout # => Hanami::View::Rendering::NullLayout
      def layout(value = nil)
        if value.nil?
          @_layout ||= Rendering::LayoutFinder.find(@layout || configuration.layout, configuration.namespace)
        elsif !value
          @layout = Hanami::View::Rendering::NullLayout
        else
          @layout = value
        end
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View.load!
      def load!
        super

        views.each do |v|
          v.root.freeze
          v.format.freeze
          v.template.freeze
          v.layout#.freeze
          v.configuration.freeze
        end
      end
    end
  end
end
