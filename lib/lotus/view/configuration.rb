require 'set'
require 'lotus/utils/kernel'
require 'lotus/utils/load_paths'
require 'lotus/view/rendering/layout_finder'
require 'lotus/view/rendering/null_layout'

module Lotus
  module View
    class Configuration
      DEFAULT_ROOT = '.'.freeze

      attr_reader :load_paths
      attr_reader :views
      attr_reader :layouts

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

      # FIXME the layout shouldn't be loaded when the value is passed,
      # but at the loading time. This because a framework can be configured
      # *before* the actual class gets loaded.
      def layout(value = nil)
        if value
          @layout = Rendering::LayoutFinder.find(value, @namespace)
        else
          @layout
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
          c.layout     = layout
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
        @layout     = Rendering::NullLayout
      end

      alias_method :unload!, :reset!

      protected
      attr_writer :namespace, :root, :load_paths, :layout
    end
  end
end
