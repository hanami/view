require 'set'
require 'pathname'
require 'hanami/utils/class_attribute'
require 'hanami/view/version'
require 'hanami/view/configuration'
require 'hanami/view/inheritable'
require 'hanami/view/rendering'
require 'hanami/view/escape'
require 'hanami/view/dsl'
require 'hanami/view/errors'
require 'hanami/layout'
require 'hanami/presenter'

module Hanami
  # View
  #
  # @since 0.1.0
  module View
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
    # @see Hanami::View::Configuration
    #
    # @example
    #   require 'hanami/view'
    #
    #   Hanami::View.configure do
    #     root '/path/to/root'
    #   end
    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    # Duplicate Hanami::View in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Hanami::View
    #
    # @since 0.2.0
    # @api private
    #
    # @example Basic usage
    #   require 'hanami/view'
    #
    #   module MyApp
    #     View = Hanami::View.dupe
    #   end
    #
    #   MyApp::View == Hanami::View # => false
    #
    #   MyApp::View.configuration ==
    #     Hanami::View.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'hanami/view'
    #
    #   Hanami::View.configure do
    #     root '/path/to/root'
    #   end
    #
    #   module MyApp
    #     View = Hanami::View.dupe
    #   end
    #
    #   module MyApi
    #     View = Hanami::View.dupe
    #     View.configure do
    #       root '/another/root'
    #     end
    #   end
    #
    #   Hanami::View.configuration.root # => #<Pathname:/path/to/root>
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
    # @return [Module] a copy of Hanami::View
    #
    # @since 0.2.0
    #
    # @see Hanami::View#dupe
    # @see Hanami::View::Configuration
    # @see Hanami::View::Configuration#namespace
    #
    # @example Basic usage
    #   require 'hanami/view'
    #
    #   module MyApp
    #     View = Hanami::View.duplicate(self)
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
    #   require 'hanami/view'
    #
    #   module MyApp
    #     View = Hanami::View.duplicate(self) do
    #       # ...
    #     end
    #   end
    #
    #   # it's equivalent to:
    #
    #   module MyApp
    #     View   = Hanami::View.dupe
    #     Layout = Hanami::Layout.dup
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
    #   require 'hanami/view
    #
    #   module MyApp
    #     View = Hanami::View.duplicate(self, 'Vs')
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
    #   require 'hanami/view'
    #
    #   module MyApp
    #     View = Hanami::View.duplicate(self, nil)
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
    #   require 'hanami/view'
    #
    #   module MyApp
    #     View = Hanami::View.duplicate(self) do
    #       root '/path/to/root'
    #     end
    #   end
    #
    #   Hanami::View.configuration.root # => #<Pathname:.>
    #   MyApp::View.configuration.root # => #<Pathname:/path/to/root>
    def self.duplicate(mod, views = 'Views', &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{ module #{ views }; end } if views
        mod.module_eval %{
          Layout = Hanami::Layout.dup
          Presenter = Hanami::Presenter.dup
        }

        duplicated.configure do
          namespace [mod, views].compact.join '::'
        end

        duplicated.configure(&blk) if block_given?
      end
    end

    # Override Ruby's hook for modules.
    # It includes basic Hanami::View modules to the given Class.
    # It sets a copy of the framework configuration
    #
    # @param base [Class] the target view
    #
    # @since 0.1.0
    # @api private
    #
    # @see http://www.ruby-doc.org/core-2.1.2/Module.html#method-i-included
    #
    # @see Hanami::View::Dsl
    # @see Hanami::View::Inheritable
    # @see Hanami::View::Rendering
    #
    # @example
    #   require 'hanami/view'
    #
    #   class IndexView
    #     include Hanami::View
    #   end
    def self.included(base)
      conf = self.configuration
      conf.add_view(base)

      base.class_eval do
        extend Inheritable
        extend Dsl
        extend Rendering
        extend Escape

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
