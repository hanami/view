require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/view/rendering/null_layout'

module Lotus
  module View
    module Rendering
      # Defines the logic to find a layout
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout
      class LayoutFinder
        # Layout class name suffix
        #
        # @api private
        # @since 0.1.0
        SUFFIX = 'Layout'.freeze

        # Find a layout from the given name.
        #
        # @param layout [Symbol,String,NilClass] layout name or nil if you want
        #   to fallback to the framework defaults (see `Lotus::View.layout`).
        #
        # @param namespace [Class,Module] a Ruby namespace where to lookup
        #
        # @return [Lotus::Layout] the layout for the given name or
        #   `Lotus::View.layout`
        #
        # @api private
        # @since 0.1.0
        #
        # @example With given name
        #   require 'lotus/view'
        #
        #   Lotus::View::Rendering::LayoutFinder.find(:article) # =>
        #     ArticleLayout
        #
        # @example With a class
        #   require 'lotus/view'
        #
        #   Lotus::View::Rendering::LayoutFinder.find(ArticleLayout) # =>
        #     ArticleLayout
        #
        # @example With namespace
        #   require 'lotus/view'
        #
        #   Lotus::View::Rendering::LayoutFinder.find(:application, CardDeck) # =>
        #     CardDeck::ApplicationLayout
        #
        # @example With nil
        #   require 'lotus/view'
        #
        #   Lotus::View::Rendering::LayoutFinder.find(nil) # =>
        #     Lotus::View::Rendering::NullLayout
        #
        # @example With unknown layout
        #   require 'lotus/view'
        #
        #   Lotus::View::Rendering::LayoutFinder.find(:unknown) # =>
        #     Lotus::View::Rendering::NullLayout
        #
        def self.find(layout, namespace = Object)
          case layout
          when Symbol, String
            # TODO Move this low level logic into a Lotus::Utils solution
            class_name = "#{ Utils::String.new(layout).classify }#{ SUFFIX }"
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
        # @return [Lotus::Layout] the layout associated to the view
        #
        # @see Lotus::View::Rendering::LayoutFinder.find
        # @see Lotus::View::Rendering::LayoutFinder#initialize
        #
        # @api private
        # @since 0.1.0
        #
        # @example With layout
        #   require 'lotus/view'
        #
        #   module Articles
        #     class Show
        #       include Lotus::View
        #       layout :article
        #     end
        #   end
        #
        #   Lotus::View::Rendering::LayoutFinder.new(Articles::Show) # =>
        #     ArticleLayout
        #
        # @example Without layout
        #   require 'lotus/view'
        #
        #   module Dashboard
        #     class Index
        #       include Lotus::View
        #     end
        #   end
        #
        #   Lotus::View.layout # => :application
        #
        #   Lotus::View::Rendering::LayoutFinder.new(Dashboard::Index) # =>
        #     ApplicationLayout
        def find
          self.class.find(@view.layout)
        end
      end
    end
  end
end
