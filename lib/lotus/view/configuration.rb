require 'lotus/utils/kernel'
require 'lotus/utils/load_paths'
require 'lotus/view/rendering/layout_finder'
require 'lotus/view/rendering/null_layout'

module Lotus
  module View
    class Configuration
      DEFAULT_ROOT = '.'.freeze

      attr_reader :load_paths

      def initialize
        reset!
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
          @layout = Rendering::LayoutFinder.find(value)
        else
          @layout
        end
      end

      def reset!
        root(DEFAULT_ROOT)

        @load_paths = Utils::LoadPaths.new(root)
        @layout     = Rendering::NullLayout
      end
    end
  end
end
