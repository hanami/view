require 'tilt'
require 'dry-equalizer'

module Dry
  module View
    class Renderer
      PARTIAL_PREFIX = "_".freeze
      PATH_DELIMITER = "/".freeze

      include Dry::Equalizer(:paths, :format, :options)

      TemplateNotFoundError = Class.new(StandardError)

      attr_reader :paths, :format, :options, :tilts

      def self.tilts
        @__engines__ ||= {}
      end

      def initialize(paths, format:, **options)
        @paths = paths
        @format = format
        @options = options
        @tilts = self.class.tilts
      end

      def template(name, scope, &block)
        path = lookup(name)

        if path
          render(path, scope, &block)
        else
          msg = "Template #{name.inspect} could not be found in paths:\n#{paths.map { |pa| "- #{pa.to_s}" }.join("\n")}"
          raise TemplateNotFoundError, msg
        end
      end

      def partial(name, scope, &block)
        template(name_for_partial(name), scope, &block)
      end

      def render(path, scope, &block)
        tilt(path).render(scope, &block)
      end

      def chdir(dirname)
        new_paths = paths.map { |path| path.chdir(dirname) }

        self.class.new(new_paths, format: format, **options)
      end

      def lookup(name)
        paths.inject(false) { |result, path|
          result || path.lookup(name, format)
        }
      end

      private

      def name_for_partial(name)
        name_segments = name.to_s.split(PATH_DELIMITER)
        partial_name = name_segments[0..-2].push("#{PARTIAL_PREFIX}#{name_segments[-1]}").join(PATH_DELIMITER)
      end

      def tilt(path)
        tilts.fetch(path) {
          tilts[path] = Tilt.new(path, nil, **options)
        }
      end
    end
  end
end
