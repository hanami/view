require "pathname"

module Dry
  module View
    class Path
      include Dry::Equalizer(:dir, :root)

      attr_reader :dir, :root

      def initialize(dir, options = {})
        @dir = Pathname(dir)
        @root = Pathname(options.fetch(:root, dir))
      end

      def lookup(name)
        template?(name) || template?("shared/#{name}") || !root? && chdir('..').lookup(name)
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

      def template?(name)
        dir.join(name) if File.exist?(dir.join(name))
      end
    end
  end
end
