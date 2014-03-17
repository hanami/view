require 'set'
require 'pathname'
require 'lotus/view/version'
require 'lotus/view/inheritable'
require 'lotus/view/rendering'
require 'lotus/view/dsl'
require 'lotus/view/layout'
require 'lotus/presenter'

module Lotus
  module View
    def self.included(base)
      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        extend Rendering.dup
      end

      views.add(base)
    end

    # Set the directory root where templates are located
    #
    # @param root [String] the root path
    #
    # @see Lotus::View.root
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/view'
    #
    #   Lotus::View.root = '/path/to/templates'
    def self.root=(root)
      @root = Pathname.new(root) rescue nil
    end

    # Returns the directory root where templates are located.
    # If not already set, it returns the current directory.
    #
    # @return [Pathname] the root path for templates
    #
    # @see Lotus::View.root=
    #
    # @since 0.1.0
    #
    # @example with already set value
    #   require 'lotus/view'
    #
    #   Lotus::View.root = '/path/to/templates'
    #   Lotus::View.root # => #<Pathname:/path/to/templates>
    #
    # @example with missing set value
    #   require 'lotus/view'
    #
    #   Lotus::View.root # => #<Pathname:.>
    def self.root
      @root ||= begin
        self.root = '.'
        @root
      end
    end

    # Sets the default layout for all the registered views.
    #
    # @param layout [Symbol] the layout name
    #
    # @since 0.1.0
    #
    # @see Lotus::View::Dsl#layout
    # @see Lotus::View.load!
    #
    # @example
    #   require 'lotus/view'
    #
    #   Lotus::View.layout = :application
    #
    #   class IndexView
    #     include Lotus::View
    #   end
    #
    #   Lotus::View.load!
    #   IndexView.layout # => ApplicationLayout
    def self.layout=(layout)
      @layout = Rendering::LayoutFinder.find(layout)
    end

    # Returns the default layout to assign to the registered views.
    # If not already set, it returns a <tt>Rendering::NullLayout</tt>.
    #
    # @return [Class,Rendering::NullLayout] depends if already set or not.
    #
    # @since 0.1.0
    #
    # @see Lotus::View.layout=
    def self.layout
      @layout ||= Rendering::NullLayout
    end

    # A set of registered views.
    #
    # @return [Set] all the registered views.
    #
    # @api private
    # @since 0.1.0
    def self.views
      @views ||= Set.new
    end

    # A set of registered layouts.
    #
    # @return [Set] all the registered layout.
    #
    # @api private
    # @since 0.1.0
    def self.layouts
      @layouts ||= Set.new
    end

    #FIXME extract a Loader class
    def self.load!
      root.freeze
      layout.freeze
      views.freeze

      views.each do |view|
        view.send(:load!)
      end

      layouts.each do |layout|
        layout.send(:load!)
      end
    end
  end
end
