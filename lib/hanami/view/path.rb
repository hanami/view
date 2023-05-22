require "pathname"

module Hanami
  class View
    # @api private
    class Path
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

      # Searches for a template using a wildcard for the engine extension
      def lookup(prefix, name, format)
        glob = dir.join(prefix, "#{name}.#{format}.*")
        Dir[glob].first
      end

      def chdir(dirname)
        self.class.new(dir.join(dirname), root: root)
      end

      def to_s
        dir.to_s
      end
    end
  end
end
