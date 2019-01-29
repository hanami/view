require "dry/core/cache"
require "dry/equalizer"
require_relative "tilt"

module Dry
  class View
    # @api private
    class Renderer
      PARTIAL_PREFIX = "_".freeze
      PATH_DELIMITER = "/".freeze

      extend Dry::Core::Cache

      include Dry::Equalizer(:paths, :format, :engine_mapping, :options)

      TemplateNotFoundError = Class.new(StandardError)

      attr_reader :paths, :format, :engine_mapping, :options

      def initialize(paths, format:, engine_mapping: nil, **options)
        @paths = paths
        @format = format
        @engine_mapping = engine_mapping || {}
        @options = options
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
        paths.inject(false) { |_, path|
          result = path.lookup(name, format, include_shared: false)
          break result if result
        }
      end

      private

      def name_for_partial(name)
        name_segments = name.to_s.split(PATH_DELIMITER)
        name_segments[0..-2].push("#{PARTIAL_PREFIX}#{name_segments[-1]}").join(PATH_DELIMITER)
      end

      def tilt(path)
        fetch_or_store(:engine, path, engine_mapping, options) {
          Tilt[path, engine_mapping, **options]
        }
      end
    end
  end
end
