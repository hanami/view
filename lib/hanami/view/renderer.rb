# frozen_string_literal: true

require "dry/core/equalizer"
require_relative "errors"
require_relative "tilt"

module Hanami
  class View
    # @api private
    class Renderer
      PARTIAL_PREFIX = "_"
      PATH_DELIMITER = "/"

      include Dry::Equalizer(:config, :format)
      attr_reader :cache, :config, :format, :prefixes

      def initialize(cache, config, format)
        @cache = cache
        @config = config
        @format = format
        @prefixes = ["."]
      end

      def template(name, scope, &block)
        old_prefixes = @prefixes

        template_path = lookup(name)

        raise TemplateNotFoundError.new(name, format, config.paths) unless template_path

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

      private

      def lookup(name)
        cache.fetch_or_store([:lookup, config.paths, prefixes, name].hash) {
          catch :found do
            config.paths.reduce(nil) do |_, path|
              prefixes.each do |prefix|
                result = path.lookup(prefix, name, format)
                throw :found, result if result
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
        cache.fetch_or_store([:engine, path, config].hash) {
          Tilt[path, config.renderer_engine_mapping, **config.renderer_options]
        }
      end
    end
  end
end
