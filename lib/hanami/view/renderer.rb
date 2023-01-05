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

      include Dry::Equalizer(:paths, :prefixes, :format, :engine_mapping, :options)

      attr_reader :paths, :prefixes, :format, :engine_mapping, :options

      def initialize(paths, format:, engine_mapping: nil, **options)
        @paths = paths
        @prefixes = ["."]
        @format = format
        @engine_mapping = engine_mapping || {}
        @options = options
      end

      def template(name, scope, &block)
        old_prefixes = @prefixes

        template_path, found_in_path = lookup(name)

        raise TemplateNotFoundError.new(name, format, paths) unless template_path

        # new_prefix = File.dirname(Pathname(template_path).relative_path_from(found_in_path.dir))
        new_prefix = File.dirname(name)
        @prefixes << new_prefix unless @prefixes.include?(new_prefix)

        render(template_path, scope, &block)
      ensure
        @prefixes = old_prefixes
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
        fetch_or_store(:lookup, paths, prefixes, name) {
          catch :found do
            paths.reduce(nil) do |_, path|
              prefixes.each do |prefix|
                result = path.lookup(prefix, name, format)
                throw :found, [result, path] if result
              end
            end
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
