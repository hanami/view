require 'set'
require 'lotus/utils/class'
require 'lotus/utils/kernel'
require 'lotus/utils/string'
require 'lotus/utils/load_paths'
require 'lotus/view/rendering/layout_finder'

module Lotus
  module View
    class Configuration
      DEFAULT_ROOT = '.'.freeze

      attr_reader :load_paths
      attr_reader :views
      attr_reader :layouts

      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load!("(#{namespace}|Lotus)::View")
        framework.configuration
      end

      def initialize
        @namespace = Object
        reset!
      end

      def namespace(value = nil)
        if value
          @namespace = value
        else
          @namespace
        end
      end

      def root(value = nil)
        if value
          @root = Utils::Kernel.Pathname(value).realpath
        else
          @root
        end
      end

      def layout(value = nil)
        if value
          @layout = value
        else
          Rendering::LayoutFinder.find(@layout, @namespace)
        end
      end

      def add_view(view)
        @views.add(view)
      end

      def add_layout(layout)
        @layouts.add(layout)
      end

      def duplicate
        Configuration.new.tap do |c|
          c.namespace  = namespace
          c.root       = root
          c.layout     = @layout # lazy loading of the class
          c.load_paths = load_paths.dup
        end
      end

      def load!
        views.each   {|v| v.__send__(:load!) }
        layouts.each {|l| l.__send__(:load!) }
      end

      def reset!
        root(DEFAULT_ROOT)

        @views      = Set.new
        @layouts    = Set.new
        @load_paths = Utils::LoadPaths.new(root)
        @layout     = nil
      end

      alias_method :unload!, :reset!

      protected
      attr_writer :namespace, :root, :load_paths, :layout
    end
  end
end
