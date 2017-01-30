require 'dry-configurable'
require 'dry-equalizer'

require 'dry/view/path'
require 'dry/view/exposures'
require 'dry/view/renderer'
require 'dry/view/scope'

module Dry
  module View
    class Controller
      DEFAULT_LAYOUTS_DIR = 'layouts'.freeze
      DEFAULT_CONTEXT = Object.new.freeze
      EMPTY_LOCALS = {}.freeze

      include Dry::Equalizer(:config)

      extend Dry::Configurable

      setting :paths
      setting :layout, false
      setting :context, DEFAULT_CONTEXT
      setting :template
      setting :default_format, :html

      attr_reader :config
      attr_reader :layout_dir
      attr_reader :layout_path
      attr_reader :template_path
      attr_reader :exposures

      def self.paths
        Array(config.paths).map { |path| Dry::View::Path.new(path) }
      end

      def self.renderer(format)
        renderers.fetch(format) {
          renderers[format] = Renderer.new(paths, format: format)
        }
      end

      def self.renderers
        @renderers ||= {}
      end

      def self.expose(*names, **options, &block)
        if names.length == 1
          exposures.add(names.first, block, **options)
        else
          names.each do |name|
            exposures.add(name, **options)
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
        @layout_dir = DEFAULT_LAYOUTS_DIR
        @layout_path = "#{layout_dir}/#{config.layout}"
        @template_path = config.template
        @exposures = self.class.exposures.bind(self)
      end

      def call(format: config.default_format, **input)
        renderer = self.class.renderer(format)

        template_content = renderer.(template_path, template_scope(renderer, **input))

        return template_content unless layout?

        renderer.(layout_path, layout_scope(renderer, **input)) do
          template_content
        end
      end

      def locals(locals: EMPTY_LOCALS, **input)
        exposures.locals(input).merge(locals)
      end

      private

      def layout?
        !!config.layout
      end

      def layout_scope(renderer, context: config.context, **)
        scope(renderer.chdir(layout_dir), EMPTY_LOCALS, context)
      end

      def template_scope(renderer, context: config.context, **input)
        scope(renderer.chdir(template_path), locals(**input), context)
      end

      def scope(renderer, locals, context)
        Scope.new(renderer, locals, context)
      end
    end
  end
end
