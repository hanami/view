# frozen_string_literal: true

require "dry/core/cache"
require "dry/core/equalizer"
require_relative "errors"
require_relative "tilt"

module Hanami
  class View
    # @api private
    class Renderer
      PARTIAL_PREFIX = "_"
      PATH_DELIMITER = "/"

      extend Dry::Core::Cache

      include Dry::Equalizer(:paths, :format, :engine_mapping, :options)

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
          raise TemplateNotFoundError.new(name, format, paths)
        end
      end

      def partial(name, scope, &block)
        template(name_for_partial(name), scope, &block)
      end

      def render(path, scope, &block)
        tilt(path).render(scope, {locals: scope._locals}, &block)
      end

      def chdir(dirname)
        new_paths = paths.map { |path| path.chdir(dirname) }

        self.class.new(new_paths, format: format, **options)
      end

      private

      def lookup(name)
        fetch_or_store(:lookup, paths, name) {
          paths.reduce(nil) do |_, path|
            result = path.lookup(name, format)
            break result if result
          end
        }
      end

      def name_for_partial(name)
        segments = name.to_s.split(PATH_DELIMITER)
        segments[-1] = "_#{segments[-1]}"
        segments.join(PATH_DELIMITER)
      end

      def tilt(path)
        fetch_or_store(:engine, path, engine_mapping, options) {
          Tilt[path, engine_mapping, **options]
        }
      end
    end
  end
end
