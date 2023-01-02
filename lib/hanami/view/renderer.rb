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
        template(
          name_for_partial(name),
          scope,
          # child_dirs: %w[shared],
          # parent_dir: true,
          &block
        )
      end

      def render(path, scope, &block)
        # tilt(path).render(scope, {locals: scope._locals}, &block)
        tilt_template(path).render(scope, {locals: scope._locals}, &block)
      end

      private

      def lookup(name)
        paths.each do |path|
          result = path.lookup(name, format)
          return result if result
        end
      end

      # Renames "foo/bar/baz" to "foo/bar/_baz"
      def name_for_partial(name)
        fetch_or_store(:partial_name, name) {
          name_segments = name.to_s.split(PATH_DELIMITER)
          name_segments[0..-2].push("#{PARTIAL_PREFIX}#{name_segments[-1]}").join(PATH_DELIMITER)
        }
      end

      def tilt_template(path)
        fetch_or_store(:tilt_template, path) {
          ext = File.extname(path).sub(/^./, "").to_sym
          Tilt.send :activate_adapter, ext

          tilt.new(path, options) # do we need to splat these options still?
        }
      end

      def tilt
        # TODO: need to activate our internal tilt "adapters" here
        # TODO: engine_mapping could be frozen and have its hash cached?
        fetch_or_store(:tilt, engine_mapping) { Tilt.mapping(engine_mapping) }
      end

      # def tilt(path)
      #   fetch_or_store(:engine, path, engine_mapping, options) {
      #     Tilt[path, engine_mapping, **options]
      #   }
      # end
    end
  end
end
