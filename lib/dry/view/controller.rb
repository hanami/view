require 'dry-configurable'
require 'dry-equalizer'
require 'inflecto'

require 'dry/view/path'
require 'dry/view/exposures'
require 'dry/view/part'
require 'dry/view/value_part'
require 'dry/view/null_part'
require 'dry/view/renderer'

module Dry
  module View
    class Controller
      include Dry::Equalizer(:config)

      DEFAULT_DIR = 'layouts'.freeze

      extend Dry::Configurable

      setting :paths
      setting :layout
      setting :template
      setting :formats, { html: :erb }
      setting :scope

      attr_reader :config
      attr_reader :scope
      attr_reader :layout_dir
      attr_reader :layout_path
      attr_reader :template_path
      attr_reader :default_format
      attr_reader :exposures

      def self.paths
        Array(config.paths).map { |path| Dry::View::Path.new(path) }
      end

      def self.renderer(format = default_format)
        unless config.formats.key?(format.to_sym)
          raise ArgumentError, "format +#{format}+ is not configured"
        end

        renderers[format]
      end

      def self.renderers
        @renderers ||= Hash.new do |h, key|
          h[key.to_sym] = Renderer.new(paths, format: key, engine: config.formats[key.to_sym])
        end
      end

      def self.default_format
        config.formats.keys.first
      end

      def self.expose(name, &block)
        exposures.add(name, block)
      end

      def self.private_expose(name, &block)
        exposures.add(name, block, to_view: false)
      end

      def self.exposures
        @exposures ||= Exposures.new
      end

      def initialize
        @config = self.class.config
        @default_format = self.class.default_format
        @layout_dir = DEFAULT_DIR
        @layout_path = "#{layout_dir}/#{config.layout}"
        @template_path = config.template
        @scope = config.scope
        @exposures = self.class.exposures.bind(self)
      end

      def call(options = {})
        renderer = self.class.renderer(options.fetch(:format, default_format))

        template_content = renderer.(template_path, template_scope(options, renderer))

        renderer.(layout_path, layout_scope(options, renderer)) do
          template_content
        end
      end

      def locals(options = {})
        exposures.locals(options).merge(options.fetch(:locals, {}))
      end

      private

      def layout_scope(options, renderer)
        part_hash = {
          page: layout_part(:page, renderer, options.fetch(:scope, scope))
        }

        part(layout_dir, renderer, part_hash)
      end

      def template_scope(options, renderer)
        view_parts(locals(options), renderer)
      end

      def view_parts(locals, renderer)
        return empty_part(template_path, renderer) unless locals.any?

        part_hash = locals.each_with_object({}) do |(key, value), result|
          part =
            case value
            when Array
              el_key = Inflecto.singularize(key).to_sym

              template_part(
                key, renderer,
                value.map { |element| template_part(el_key, renderer, element) }
              )
            else
              template_part(key, renderer, value)
            end

          result[key] = part
        end

        part(template_path, renderer, part_hash)
      end

      def layout_part(name, renderer, value)
        part(layout_dir, renderer, { name => value })
      end

      def template_part(name, renderer, value)
        part(template_path, renderer, { name => value })
      end

      def part(dir, renderer, value = {})
        part_class = value.values[0] ? ValuePart : NullPart
        part_class.new(renderer.chdir(dir), value)
      end

      def empty_part(dir, renderer)
        Part.new(renderer.chdir(dir))
      end
    end
  end
end
