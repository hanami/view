require 'tilt'
require 'dry-equalizer'

module Dry
  module View
    class Renderer
      PARTIAL_PREFIX = "_".freeze
      PATH_DELIMITER = "/".freeze

      include Dry::Equalizer(:paths, :format)

      TemplateNotFoundError = Class.new(StandardError)

      attr_reader :paths, :format, :engine, :tilts

      def self.tilts
        @__engines__ ||= {}
      end

      def initialize(paths, format:)
        @paths = paths
        @format = format
        @tilts = self.class.tilts
      end

      def call(template, scope, &block)
        path = lookup(template)

        if path
          render(path, scope, &block)
        else
          msg = "Template #{template.inspect} could not be found in paths:\n#{paths.map { |pa| "- #{pa.to_s}" }.join("\n")}"
          raise TemplateNotFoundError, msg
        end
      end

      def partial(template, scope, &block)
        path = lookup_partial(template)

        if path
          render(path, scope, &block)
        else
          msg = "Partial #{template.inspect} could not be found in paths:\n#{paths.map { |pa| "- #{pa.to_s}" }.join("\n")}"
          raise TemplateNotFoundError, msg
        end
      end

      def render(path, scope, &block)
        tilt(path).render(scope, &block)
      end

      def chdir(dirname)
        new_paths = paths.map { |path| path.chdir(dirname) }

        self.class.new(new_paths, format: format)
      end

      def lookup(name)
        paths.inject(false) { |result, path|
          result || path.lookup(name, format)
        }
      end

      def lookup_partial(name)
        name_segments = name.to_s.split(PATH_DELIMITER)
        partial_name = name_segments[0..-2].push("#{PARTIAL_PREFIX}#{name_segments[-1]}").join(PATH_DELIMITER)

        lookup(partial_name)
      end

      private

      # TODO: make default_encoding configurable
      def tilt(path)
        tilts.fetch(path) {
          tilts[path] = Tilt.new(path, nil, default_encoding: "utf-8")
        }
      end
    end
  end
end
