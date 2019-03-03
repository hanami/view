# frozen_string_literal: true

require "pathname"
require "dry/core/cache"

module Dry
  class View
    # @api private
    class Path
      extend Dry::Core::Cache
      include Dry::Equalizer(:dir, :root)

      attr_reader :dir, :root

      def self.[](path)
        if path.is_a?(self)
          path
        else
          new(path)
        end
      end

      def initialize(dir, root: dir)
        @dir = Pathname(dir)
        @root = Pathname(root)
      end

      def lookup(name, format, include_shared: true)
        fetch_or_store(dir, root, name, format) do
          template?(name, format) ||
            (include_shared && template?("shared/#{name}", format)) ||
            !root? && chdir("..").lookup(name, format)
        end
      end

      def chdir(dirname)
        self.class.new(dir.join(dirname), root: root)
      end

      def to_s
        dir
      end

      private

      def root?
        dir == root
      end

      # Search for a template using a wildcard for the engine extension
      def template?(name, format)
        glob = dir.join("#{name}.#{format}.*")
        Dir[glob].first
      end
    end
  end
end
