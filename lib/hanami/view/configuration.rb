require 'set'
require 'hanami/utils/class'
require 'hanami/utils/kernel'
require 'hanami/utils/string'
require 'hanami/utils/load_paths'
require 'hanami/view/rendering/layout_finder'
require 'hanami/view/rendering/partial_templates_finder'

module Hanami
  module View
    # Configuration for the framework, controllers and actions.
    #
    # Hanami::Controller has its own global configuration that can be manipulated
    # via `Hanami::View.configure`.
    #
    # Every time that `Hanami::View` and `Hanami::Layout` are included, that
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

      # Default encoding
      #
      # @since 0.5.0
      # @api private
      DEFAULT_ENCODING = Encoding::UTF_8

      attr_reader :load_paths
      attr_reader :views
      attr_reader :layouts
      attr_reader :modules
      attr_reader :partials

      # Return the original configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Hanami::View are used in the same application,
      # we want to make sure that a controller or an action will  receive the
      # expected configuration.
      #
      # @param base [Class] a view or a layout
      #
      # @return [Hanami::Controller::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.2.0
      # @api private
      #
      # @example Direct usage of the framework
      #   require 'hanami/view'
      #
      #   class Show
      #     include Hanami::View
      #   end
      #
      #   Hanami::View::Configuration.for(Show)
      #     # => will return from Hanami::View
      #
      # @example Multiple instances of the framework
      #   require 'hanami/view'
      #
      #   module MyApp
      #     View = Hanami::View.duplicate(self)
      #
      #     module Views::Dashboard
      #       class Index
      #         include MyApp::View
      #       end
      #     end
      #   end
      #
      #   class Show
      #     include Hanami::Action
      #   end
      #
      #   Hanami::View::Configuration.for(Show)
      #     # => will return from Hanami::View
      #
      #   Hanami::View::Configuration.for(MyApp::Views::Dashboard::Index)
      #     # => will return from MyApp::View
      def self.for(base)
        # TODO this implementation is similar to Hanami::Controller::Configuration consider to extract it into Hanami::Utils
        namespace = Utils::String.namespace(base)
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Hanami)::View")
        framework.configuration
      end

      # Initialize a configuration instance
      #
      # @return [Hanami::View::Configuration] a new configuration's instance
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
      #   require 'hanami/view'
      #
      #   Hanami::View.configuration.namespace # => Object
      #
      # @example Setting the value
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
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
      # @see Hanami::View::Dsl#root
      # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Pathname-class_method
      #
      # @example Getting the value
      #   require 'hanami/view'
      #
      #   Hanami::View.configuration.root # => #<Pathname:.>
      #
      # @example Setting the value
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     root '/path/to/templates'
      #   end
      #
      #   Hanami::View.configuration.root # => #<Pathname:/path/to/templates>
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
      # it will use `Hanami::View::Rendering::NullLayout`.
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
      # @see Hanami::View::Dsl#layout
      #
      # @example Getting the value
      #   require 'hanami/view'
      #
      #   Hanami::View.configuration.layout # => nil
      #
      # @example Setting the value
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     layout :application
      #   end
      #
      #   Hanami::View.configuration.layout # => ApplicationLayout
      #
      # @example Setting the value in a namespaced app
      #   require 'hanami/view'
      #
      #   module MyApp
      #     View = Hanami::View.duplicate(self) do
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

      # Default encoding for templates
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload default_encoding(value)
      #   Sets the given value
      #   @param value [String,Encoding] a string representation of the encoding,
      #     or an Encoding constant
      #
      #   @raise [ArgumentError] if the given value isn't a supported encoding
      #
      # @overload default_encoding
      #   Gets the value
      #   @return [Encoding]
      #
      # @since 0.5.0
      #
      # @example Set UTF-8 As A String
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     default_encoding 'utf-8'
      #   end
      #
      # @example Set UTF-8 As An Encoding Constant
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     default_encoding Encoding::UTF_8
      #   end
      #
      # @example Raise An Error For Unknown Encoding
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     default_encoding 'foo'
      #   end
      #
      #     # => ArgumentError
      def default_encoding(value = nil)
        if value.nil?
          @default_encoding
        else
          @default_encoding = Encoding.find(value)
        end
      end

      # Prepare the views.
      #
      # The given block will be yielded when `Hanami::View` will be included by
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
      # @see Hanami::View.configure
      # @see Hanami::View.duplicate
      #
      # @example Including shared utilities
      #   require 'hanami/view'
      #
      #   module UrlHelpers
      #     def comments_path
      #       '/'
      #     end
      #   end
      #
      #   Hanami::View.configure do
      #     prepare do
      #       include UrlHelpers
      #     end
      #   end
      #
      #   Hanami::View.load!
      #
      #   module Comments
      #     class New
      #       # The following include will cause UrlHelpers to be included too.
      #       # This makes `comments_path` available in the view context
      #       include Hanami::View
      #
      #       def form
      #         %(<form action="#{ comments_path }" method="POST"></form>)
      #       end
      #     end
      #   end
      #
      # @example Preparing multiple times
      #   require 'hanami/view'
      #
      #   Hanami::View.configure do
      #     prepare do
      #       include UrlHelpers
      #     end
      #
      #     prepare do
      #       format :json
      #     end
      #   end
      #
      #   Hanami::View.configure do
      #     prepare do
      #       include FormattingHelpers
      #     end
      #   end
      #
      #   Hanami::View.load!
      #
      #   module Articles
      #     class Index
      #       # The following include will cause the inclusion of:
      #       #   * UrlHelpers
      #       #   * FormattingHelpers
      #       #
      #       # It also sets the view to render only JSON
      #       include Hanami::View
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
      # @return [Hanami::View::Configuration] a copy of the configuration
      #
      # @since 0.2.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.namespace        = namespace
          c.root             = root
          c.layout           = @layout # lazy loading of the class
          c.default_encoding = default_encoding
          c.load_paths       = load_paths.dup
          c.modules          = modules.dup
        end
      end

      # Load the configuration for the current framework
      #
      # @since 0.2.0
      # @api private
      def load!
        views.each   { |v| v.__send__(:load!) }
        layouts.each { |l| l.__send__(:load!) }
        load_partials!
        freeze
      end

      # Load partials for each partial template file found under the
      # given load paths
      #
      # @since 0.7.0
      # @api private
      def load_partials!
        Hanami::View::Rendering::PartialTemplatesFinder.new(self).find.each do |partial|
          add_partial(partial)
        end
      end

      # Load partials for each partial template file found under the
      # given load paths
      #
      # @since 0.7.0
      # @api private
      def find_partial(relative_partial_path, template_name, format)
        partials_for_view = partials.has_key?(relative_partial_path) ?  partials[relative_partial_path] : partials[template_name]
        partials_for_view ? partials_for_view[format.to_sym] : nil
      end

      # Add a partial to the registry
      #
      # @since 0.7.0
      # @api private
      def add_partial(partial)
        @partials[partial.key][partial.format.to_sym] = partial.template
      end

      # Reset all the values to the defaults
      #
      # @since 0.2.0
      # @api private
      def reset!
        root             DEFAULT_ROOT
        default_encoding DEFAULT_ENCODING

        @partials   = Hash.new { |h, k| h[k] = Hash.new }
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

      # @api private
      alias_method :unload!, :reset!

      protected
      # @api private
      attr_writer :namespace
      # @api private
      attr_writer :root
      # @api private
      attr_writer :load_paths
      # @api private
      attr_writer :layout
      # @api private
      attr_writer :default_encoding
      # @api private
      attr_writer :modules
    end
  end
end
