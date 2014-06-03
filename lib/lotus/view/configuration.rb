require 'lotus/utils/kernel'

module Lotus
  module View
    class Configuration
      DEFAULT_ROOT = '.'.freeze

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
      end
    end
  end
end
