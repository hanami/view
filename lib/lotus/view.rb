require 'set'
require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/view/version'
require 'lotus/view/configuration'
require 'lotus/view/inheritable'
require 'lotus/view/rendering'
require 'lotus/view/escape'
require 'lotus/view/dsl'
require 'lotus/layout'
require 'lotus/presenter'

module Lotus
  # View
  #
  # @since 0.1.0
  module View
    # Missing template error
    #
    # This is raised at the runtime when Lotus::View cannot find a template for
    # the requested format.
    #
    # We can't raise this error during the loading phase, because at that time
    # we don't know if a view implements its own rendering policy.
    # A view is allowed to override `#render`, and this scenario can make the
    # presence of a template useless. One typical example is the usage of a
    # serializer that returns the output string, without rendering a template.
    #
    # @since 0.1.0
    class MissingTemplateError < ::StandardError
      def initialize(template, format)
        super("Can't find template '#{ template }' for '#{ format }' format.")
      end
    end

    # Missing format error
    #
    # This is raised at the runtime when rendering context lacks of the :format
    # key.
    #
    # @since 0.1.0
    #
    # @see Lotus::View::Rendering#render
    class MissingFormatError < ::StandardError
    end

    include Utils::ClassAttribute

    # Framework configuration
    #
    # @since 0.2.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.2.0
    #
    # @see Lotus::View::Configuration
    #
    # @example
    #   require 'lotus/view'
    #
    #   Lotus::View.configure do
    #     root '/path/to/root'
    #   end
    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    # Duplicate Lotus::View in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Lotus::View
    #
    # @since 0.2.0
    # @api private
    #
    # @example Basic usage
    #   require 'lotus/view'
    #
    #   module MyApp
    #     View = Lotus::View.dupe
    #   end
    #
    #   MyApp::View == Lotus::View # => false
    #
    #   MyApp::View.configuration ==
    #     Lotus::View.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'lotus/view'
    #
    #   Lotus::View.configure do
    #     root '/path/to/root'
    #   end
    #
    #   module MyApp
    #     View = Lotus::View.dupe
    #   end
    #
    #   module MyApi
    #     View = Lotus::View.dupe
    #     View.configure do
    #       root '/another/root'
    #     end
    #   end
    #
    #   Lotus::View.configuration.root # => #<Pathname:/path/to/root>
    #   MyApp::View.configuration.root # => #<Pathname:/path/to/root>
    #   MyApi::View.configuration.root # => #<Pathname:/another/root>
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param mod [Module] the Ruby namespace of the application
    # @param views [String] the optional namespace where the application's
    #   views will live
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Lotus::View
    #
    # @since 0.2.0
    #
    # @see Lotus::View#dupe
    # @see Lotus::View::Configuration
    # @see Lotus::View::Configuration#namespace
    #
    # @example Basic usage
    #   require 'lotus/view'
    #
    #   module MyApp
    #     View = Lotus::View.duplicate(self)
    #   end
    #
    #   # It will:
    #   #
    #   # 1. Generate MyApp::View
    #   # 2. Generate MyApp::Layout
    #   # 3. Generate MyApp::Presenter
    #   # 4. Generate MyApp::Views
    #   # 5. Configure MyApp::Views as the default namespace for views
    #
    #  module MyApp::Views::Dashboard
    #    class Index
    #      include MyApp::View
    #    end
    #  end
    #
    # @example Compare code
    #   require 'lotus/view'
    #
    #   module MyApp
    #     View = Lotus::View.duplicate(self) do
    #       # ...
    #     end
    #   end
    #
    #   # it's equivalent to:
    #
    #   module MyApp
    #     View   = Lotus::View.dupe
    #     Layout = Lotus::Layout.dup
    #
    #     module Views
    #     end
    #
    #     View.configure do
    #       namespace 'MyApp::Views'
    #     end
    #
    #     View.configure do
    #       # ...
    #     end
    #   end
    #
    # @example Custom views module
    #   require 'lotus/view
    #
    #   module MyApp
    #     View = Lotus::View.duplicate(self, 'Vs')
    #   end
    #
    #   defined?(MyApp::Views) # => nil
    #   defined?(MyApp::Vs)    # => "constant"
    #
    #   # Developers can namespace views under Vs
    #   module MyApp::Vs::Dashboard
    #     # ...
    #   end
    #
    # @example Nil views module
    #   require 'lotus/view'
    #
    #   module MyApp
    #     View = Lotus::View.duplicate(self, nil)
    #   end
    #
    #   defined?(MyApp::Views) # => nil
    #
    #   # Developers can namespace views under MyApp
    #   module MyApp
    #     # ...
    #   end
    #
    # @example Block usage
    #   require 'lotus/view'
    #
    #   module MyApp
    #     View = Lotus::View.duplicate(self) do
    #       root '/path/to/root'
    #     end
    #   end
    #
    #   Lotus::View.configuration.root # => #<Pathname:.>
    #   MyApp::View.configuration.root # => #<Pathname:/path/to/root>
    def self.duplicate(mod, views = 'Views', &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{ module #{ views }; end } if views
        mod.module_eval %{
          Layout = Lotus::Layout.dup
          Presenter = Lotus::Presenter.dup
        }

        duplicated.configure do
          namespace [mod, views].compact.join '::'
        end

        duplicated.configure(&blk) if block_given?
      end
    end

    # Override Ruby's hook for modules.
    # It includes basic Lotus::View modules to the given Class.
    # It sets a copy of the framework configuration
    #
    # @param base [Class] the target view
    #
    # @since 0.1.0
    # @api private
    #
    # @see http://www.ruby-doc.org/core-2.1.2/Module.html#method-i-included
    #
    # @see Lotus::View::Dsl
    # @see Lotus::View::Inheritable
    # @see Lotus::View::Rendering
    #
    # @example
    #   require 'lotus/view'
    #
    #   class IndexView
    #     include Lotus::View
    #   end
    def self.included(base)
      conf = self.configuration
      conf.add_view(base)

      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        extend Rendering.dup
        extend Escape.dup

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
      end

      conf.copy!(base)
    end

    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      configuration.load!
    end
  end
end
