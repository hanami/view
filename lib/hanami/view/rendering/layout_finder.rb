require 'hanami/utils/string'
require 'hanami/utils/class'
require 'hanami/view/rendering/null_layout'

module Hanami
  module View
    module Rendering
      # Defines the logic to find a layout
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::Layout
      class LayoutFinder
        # Layout class name suffix
        #
        # @api private
        # @since 0.1.0
        SUFFIX = 'Layout'.freeze

        # Find a layout from the given name.
        #
        # @param layout [Symbol,String,NilClass] layout name or nil if you want
        #   to fallback to the framework defaults (see `Hanami::View.layout`).
        #
        # @param namespace [Class,Module] a Ruby namespace where to lookup
        #
        # @return [Hanami::Layout] the layout for the given name or
        #   `Hanami::View.layout`
        #
        # @api private
        # @since 0.1.0
        #
        # @example With given name
        #   require 'hanami/view'
        #
        #   Hanami::View::Rendering::LayoutFinder.find(:article) # =>
        #     ArticleLayout
        #
        # @example With a class
        #   require 'hanami/view'
        #
        #   Hanami::View::Rendering::LayoutFinder.find(ArticleLayout) # =>
        #     ArticleLayout
        #
        # @example With namespace
        #   require 'hanami/view'
        #
        #   Hanami::View::Rendering::LayoutFinder.find(:application, CardDeck) # =>
        #     CardDeck::ApplicationLayout
        #
        # @example With nil
        #   require 'hanami/view'
        #
        #   Hanami::View::Rendering::LayoutFinder.find(nil) # =>
        #     Hanami::View::Rendering::NullLayout
        #
        # @example With unknown layout
        #   require 'hanami/view'
        #
        #   Hanami::View::Rendering::LayoutFinder.find(:unknown) # =>
        #     Hanami::View::Rendering::NullLayout
        #
        def self.find(layout, namespace = Object)
          case layout
          when Symbol, String
            # TODO Move this low level logic into a Hanami::Utils solution
            class_name = "#{ Utils::String.classify(layout) }#{ SUFFIX }"
            namespace  = Utils::Class.load_from_pattern!(namespace)
            namespace.const_get(class_name)
          when Class
            layout
          end || NullLayout
        end

        # Initialize the finder
        #
        # @param view [Class, #layout]
        #
        # @api private
        # @since 0.1.0
        def initialize(view)
          @view = view
        end

        # Find the layout for the view
        #
        # @return [Hanami::Layout] the layout associated to the view
        #
        # @see Hanami::View::Rendering::LayoutFinder.find
        # @see Hanami::View::Rendering::LayoutFinder#initialize
        #
        # @api private
        # @since 0.1.0
        #
        # @example With layout
        #   require 'hanami/view'
        #
        #   module Articles
        #     class Show
        #       include Hanami::View
        #       layout :article
        #     end
        #   end
        #
        #   Hanami::View::Rendering::LayoutFinder.new(Articles::Show) # =>
        #     ArticleLayout
        #
        # @example Without layout
        #   require 'hanami/view'
        #
        #   module Dashboard
        #     class Index
        #       include Hanami::View
        #     end
        #   end
        #
        #   Hanami::View.layout # => :application
        #
        #   Hanami::View::Rendering::LayoutFinder.new(Dashboard::Index) # =>
        #     ApplicationLayout
        def find
          self.class.find(@view.layout)
        end
      end
    end
  end
end
