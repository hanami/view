require 'set'
require 'lotus/utils/class'
require 'lotus/utils/kernel'
require 'lotus/utils/string'
require 'lotus/utils/load_paths'
require 'lotus/view/rendering/layout_finder'

module Lotus
  module View
    # Configuration for the framework, controllers and actions.
    #
    # Lotus::Controller has its own global configuration that can be manipulated
    # via `Lotus::View.configure`.
    #
    # Every time that `Lotus::View` and `Lotus::Layout` are included, that
    # global configuration is being copied to the recipient. The copy will
    # inherit all the settings from the original, but all the subsequent changes
    # aren't reflected from the parent to the children, and viceversa.
    #
    # This architecture allows to have a global configuration that capture the
    # most common cases for an application, and let views and layouts
    # layouts to specify exceptions.
    #
    # @since 0.2.0
    class Configuration
      # Default root
      #
      # @since 0.2.0
      # @api private
      DEFAULT_ROOT = '.'.freeze

      attr_reader :load_paths
      attr_reader :views
      attr_reader :layouts
      attr_reader :modules

      # Return the original configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Lotus::View are used in the same application,
      # we want to make sure that a controller or an action will  receive the
      # expected configuration.
      #
      # @param base [Class] a view or a layout
      #
      # @return [Lotus::Controller::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.2.0
      # @api private
      #
      # @example Direct usage of the framework
      #   require 'lotus/view'
      #
      #   class Show
      #     include Lotus::View
      #   end
      #
      #   Lotus::View::Configuration.for(Show)
      #     # => will return from Lotus::View
      #
      # @example Multiple instances of the framework
      #   require 'lotus/view'
      #
      #   module MyApp
      #     View = Lotus::View.duplicate(self)
      #
      #     module Views::Dashboard
      #       class Index
      #         include MyApp::View
      #       end
      #     end
      #   end
      #
      #   class Show
      #     include Lotus::Action
      #   end
      #
      #   Lotus::View::Configuration.for(Show)
      #     # => will return from Lotus::View
      #
      #   Lotus::View::Configuration.for(MyApp::Views::Dashboard::Index)
      #     # => will return from MyApp::View
      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::View")
        framework.configuration
      end

      # Initialize a configuration instance
      #
      # @return [Lotus::View::Configuration] a new configuration's instance
      #
      # @since 0.2.0
      def initialize
        @namespace = Object
        reset!
      end

      # Set the Ruby namespace where to lookup for views.
      #
      # When multiple instances of the framework are used, we want to make sure
      # that if a `MyApp` wants a `Dashboard::Index` view, we are loading the
      # right one.
      #
      # If not set, this value defaults to `Object`.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload namespace(value)
      #   Sets the given value
      #   @param value [Class, Module, String] a valid Ruby namespace identifier
      #
      # @overload namespace
      #   Gets the value
      #   @return [Class, Module, String]
      #
      # @since 0.2.0
      #
      # @example Getting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configuration.namespace # => Object
      #
      # @example Setting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configure do
      #     namespace 'MyApp::Views'
      #   end
      def namespace(value = nil)
        if value
          @namespace = value
        else
          @namespace
        end
      end

      # Set the root path where to search for templates
      #
      # If not set, this value defaults to the current directory.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload root(value)
      #   Sets the given value
      #   @param value [String,Pathname,#to_pathname] an object that can be
      #     coerced to Pathname
      #   @raise [Errno::ENOENT] if the given path doesn't exist
      #
      # @overload root
      #   Gets the value
      #   @return [Pathname]
      #
      # @since 0.2.0
      #
      # @see Lotus::View::Dsl#root
      # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Pathname-class_method
      #
      # @example Getting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configuration.root # => #<Pathname:.>
      #
      # @example Setting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configure do
      #     root '/path/to/templates'
      #   end
      #
      #   Lotus::View.configuration.root # => #<Pathname:/path/to/templates>
      def root(value = nil)
        if value
          @root = Utils::Kernel.Pathname(value).realpath
        else
          @root
        end
      end

      # Set the global layout
      #
      # If not set, this value defaults to `nil`, while at the rendering time
      # it will use `Lotus::View::Rendering::NullLayout`.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload layout(value)
      #   Sets the given value
      #   @param value [Symbol] the name of the layout
      #
      # @overload layout
      #   Gets the value
      #   @return [Class]
      #
      # @since 0.2.0
      #
      # @see Lotus::View::Dsl#layout
      #
      # @example Getting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configuration.layout # => nil
      #
      # @example Setting the value
      #   require 'lotus/view'
      #
      #   Lotus::View.configure do
      #     layout :application
      #   end
      #
      #   Lotus::View.configuration.layout # => ApplicationLayout
      #
      # @example Setting the value in a namespaced app
      #   require 'lotus/view'
      #
      #   module MyApp
      #     View = Lotus::View.duplicate(self) do
      #       layout :application
      #     end
      #   end
      #
      #   MyApp::View.configuration.layout # => MyApp::ApplicationLayout
      def layout(value = nil)
        if value.nil?
          Rendering::LayoutFinder.find(@layout, @namespace)
        else
          @layout = value
        end
      end

      # Prepare the views.
      #
      # The given block will be yielded when `Lotus::View` will be included by
      # a view.
      #
      # This method can be called multiple times.
      #
      # @param blk [Proc] the code block
      #
      # @return [void]
      #
      # @raise [ArgumentError] if called without passing a block
      #
      # @since 0.3.0
      #
      # @see Lotus::View.configure
      # @see Lotus::View.duplicate
      #
      # @example Including shared utilities
      #   require 'lotus/view'
      #
      #   module UrlHelpers
      #     def comments_path
      #       '/'
      #     end
      #   end
      #
      #   Lotus::View.configure do
      #     prepare do
      #       include UrlHelpers
      #     end
      #   end
      #
      #   Lotus::View.load!
      #
      #   module Comments
      #     class New
      #       # The following include will cause UrlHelpers to be included too.
      #       # This makes `comments_path` available in the view context
      #       include Lotus::View
      #
      #       def form
      #         %(<form action="#{ comments_path }" method="POST"></form>)
      #       end
      #     end
      #   end
      #
      # @example Preparing multiple times
      #   require 'lotus/view'
      #
      #   Lotus::View.configure do
      #     prepare do
      #       include UrlHelpers
      #     end
      #
      #     prepare do
      #       format :json
      #     end
      #   end
      #
      #   Lotus::View.configure do
      #     prepare do
      #       include FormattingHelpers
      #     end
      #   end
      #
      #   Lotus::View.load!
      #
      #   module Articles
      #     class Index
      #       # The following include will cause the inclusion of:
      #       #   * UrlHelpers
      #       #   * FormattingHelpers
      #       #
      #       # It also sets the view to render only JSON
      #       include Lotus::View
      #     end
      #   end
      def prepare(&blk)
        if block_given?
          @modules.push(blk)
        else
          raise ArgumentError.new('Please provide a block')
        end
      end

      # Add a view to the registry
      #
      # @since 0.2.0
      # @api private
      def add_view(view)
        @views.add(view)
      end

      # Add a layout to the registry
      #
      # @since 0.2.0
      # @api private
      def add_layout(layout)
        @layouts.add(layout)
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Lotus::View::Configuration] a copy of the configuration
      #
      # @since 0.2.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.namespace  = namespace
          c.root       = root
          c.layout     = @layout # lazy loading of the class
          c.load_paths = load_paths.dup
          c.modules    = modules.dup
        end
      end

      # Load the configuration for the current framework
      #
      # @since 0.2.0
      # @api private
      def load!
        views.each   { |v| v.__send__(:load!) }
        layouts.each { |l| l.__send__(:load!) }
        freeze
      end

      # Reset all the values to the defaults
      #
      # @since 0.2.0
      # @api private
      def reset!
        root(DEFAULT_ROOT)

        @views      = Set.new
        @layouts    = Set.new
        @load_paths = Utils::LoadPaths.new(root)
        @layout     = nil
        @modules    = []
      end

      # Copy the configuration for the given action
      #
      # @param base [Class] the target action
      #
      # @return void
      #
      # @since 0.3.0
      # @api private
      def copy!(base)
        modules.each do |mod|
          base.class_eval(&mod)
        end
      end

      alias_method :unload!, :reset!

      protected
      attr_writer :namespace
      attr_writer :root
      attr_writer :load_paths
      attr_writer :layout
      attr_writer :modules
    end
  end
end
