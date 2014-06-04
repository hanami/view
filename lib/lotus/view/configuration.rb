require 'lotus/utils/kernel'
require 'lotus/utils/load_paths'

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

      def reset!
        root(DEFAULT_ROOT)
        @load_paths = Utils::LoadPaths.new(root)
      end
    end
  end
end
