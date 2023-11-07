# frozen_string_literal: true

require "pathname"

module Hanami
  class View
    # @api private
    # @since 2.1.0
    class Path
      include Dry::Equalizer(:dir, :root)

      # @api private
      # @since 2.1.0
      attr_reader :dir, :root

      # @api private
      # @since 2.1.0
      def self.[](path)
        if path.is_a?(self)
          path
        else
          new(path)
        end
      end

      # @api private
      # @since 2.1.0
      def initialize(dir, root: dir)
        @dir = Pathname(dir)
        @root = Pathname(root)
      end

      # Searches for a template using a wildcard for the engine extension
      #
      # @api private
      # @since 2.1.0
      def lookup(prefix, name, format)
        glob = dir.join(prefix, "#{name}.#{format}.*")
        Dir[glob].first
      end

      # @api private
      # @since 2.1.0
      def chdir(dirname)
        self.class.new(dir.join(dirname), root: root)
      end

      # @api private
      # @since 2.1.0
      def to_s
        dir.to_s
      end
    end
  end
end
