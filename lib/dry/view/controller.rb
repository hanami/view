require 'dry-configurable'
require 'dry-equalizer'

require 'dry/view/path'
require 'dry/view/exposures'
require 'dry/view/renderer'
require 'dry/view/scope'

module Dry
  module View
    class Controller
      include Dry::Equalizer(:config)

      DEFAULT_LAYOUTS_DIR = 'layouts'.freeze
      LAYOUT_PART_NAME = :layout

      extend Dry::Configurable

      setting :paths
      setting :layout, false
      setting :layout_scope
      setting :template
      setting :formats, { html: :erb }

      attr_reader :config
      attr_reader :layout
      attr_reader :default_layout_scope
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

      def self.expose(*names, **options, &block)
        if names.length == 1
          exposures.add(names.first, block, **options)
        else
          names.each do |name|
            exposures.add(name, nil, **options)
          end
        end
      end

      def self.private_expose(*names, &block)
        expose(*names, to_view: false, &block)
      end

      def self.exposures
        @exposures ||= Exposures.new
      end

      def initialize
        @config = self.class.config
        @default_format = self.class.default_format
        @layout_dir = DEFAULT_LAYOUTS_DIR
        @layout = config.layout
        @layout_path = "#{layout_dir}/#{config.layout}"
        @template_path = config.template
        @default_layout_scope = config.layout_scope
        @exposures = self.class.exposures.bind(self)
      end

      def call(options = {})
        renderer = self.class.renderer(options.fetch(:format, default_format))

        template_content = renderer.(template_path, template_scope(renderer, options))

        return template_content unless layout?

        renderer.(layout_path, layout_scope(renderer, options)) do
          template_content
        end
      end

      def locals(options = {})
        exposures.locals(options).merge(options.fetch(:locals, {}))
      end

      private

      def layout?
        !!layout
      end

      def layout_scope(renderer, options)
        scope = {LAYOUT_PART_NAME => options.fetch(:layout_scope, default_layout_scope)}

        Scope.new(renderer.chdir(layout_dir), scope)
      end

      def template_scope(renderer, options)
        Scope.new(renderer.chdir(template_path), locals(options))
      end
    end
  end
end
