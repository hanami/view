# frozen_string_literal: true

require "dry/core/cache"
require "dry/equalizer"
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

      def template(name, scope, **lookup_options, &block)
        path = lookup(name, **lookup_options)

        if path
          render(path, scope, &block)
        else
          raise TemplateNotFoundError.new(name, paths)
        end
      end

      def partial(name, scope, &block)
        template(
          name_for_partial(name),
          scope,
          child_dirs: %w[shared],
          parent_dir: true,
          &block
        )
      end

      def render(path, scope, &block)
        tilt(path).render(scope, &block)
      end

      def chdir(dirname)
        new_paths = paths.map { |path| path.chdir(dirname) }

        self.class.new(new_paths, format: format, **options)
      end

      private

      def lookup(name, **options)
        paths.inject(nil) { |_, path|
          result = path.lookup(name, format, **options)
          break result if result
        }
      end

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
