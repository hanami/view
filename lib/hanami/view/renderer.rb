# frozen_string_literal: true

require_relative "errors"
require_relative "tilt"

module Hanami
  class View
    # @api private
    class Renderer
      PARTIAL_PREFIX = "_"
      PATH_DELIMITER = "/"
      CURRENT_PATH_PREFIX = "."

      attr_reader :config, :prefixes

      def initialize(config)
        @config = config
        @prefixes = [CURRENT_PATH_PREFIX]
      end

      def template(name, format, scope, &block)
        old_prefixes = @prefixes.dup

        template_path = lookup(name, format)

        raise TemplateNotFoundError.new(name, format, config.paths) unless template_path

        new_prefix = File.dirname(name)
        @prefixes << new_prefix unless @prefixes.include?(new_prefix)

        render(template_path, scope, &block)
      ensure
        @prefixes = old_prefixes
      end

      def partial(name, format, scope, &block)
        template(name_for_partial(name), format, scope, &block)
      end

      private

      def lookup(name, format)
        View.cache.fetch_or_store(:lookup, name, format, config, prefixes) {
          catch :found do
            config.paths.reduce(nil) do |_, path|
              prefixes.reduce(nil) do |_, prefix|
                result = path.lookup(prefix, name, format)
                throw :found, result if result
              end
            end
          end
        }
      end

      def name_for_partial(name)
        segments = name.to_s.split(PATH_DELIMITER)
        segments[-1] = "#{PARTIAL_PREFIX}#{segments[-1]}"
        segments.join(PATH_DELIMITER)
      end

      def render(path, scope, &block)
        tilt(path).render(scope, {locals: scope._locals}, &block).html_safe
      end

      def tilt(path)
        View.cache.fetch_or_store(:tilt, path, config) {
          Hanami::View::Tilt[path, config.renderer_engine_mapping, config.renderer_options]
        }
      end
    end
  end
end
