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
      DEFAULT_CONTEXT = Object.new.freeze

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
        @layout_dir = DEFAULT_LAYOUTS_DIR
        @layout_path = "#{layout_dir}/#{config.layout}"
        @template_path = config.template
        @exposures = self.class.exposures.bind(self)
      end

      def call(options = {})
        renderer = self.class.renderer(options.fetch(:format, config.default_format))

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
        !!config.layout
      end

      def layout_scope(renderer, options)
        context = options.fetch(:context) { config.context }

        Scope.new(renderer.chdir(layout_dir), {}, context)
      end

      def template_scope(renderer, options)
        context = options.fetch(:context) { config.context }

        Scope.new(renderer.chdir(template_path), locals(options), context)
      end
    end
  end
end
