require 'lotus/view/rendering/null_template'
require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      # Missing template layout error
      #
      # This is raised at the runtime when Lotus::Layout cannot find it's template.
      #
      # @since 0.3.0
      class MissingTemplateLayoutError < ::StandardError
        def initialize(template)
          super("Can't find layout template '#{ template }'")
        end
      end
      # Holds the references of all the registered layouts.
      # As now the registry is unique at the level of the framework.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout::ClassMethods#registry
      class LayoutRegistry
        # Initialize the registry
        #
        # @param view [Class] the view
        #
        # @api private
        # @since 0.1.0
        def initialize(view)
          @registry = {}
          @view = view
          prepare!
        end

        # Returns the layout for the given context.
        #
        # @param context [Hash] the rendering context
        # @option context [Symbol] :format the requested format
        #
        # @return [Lotus::Layout, Lotus::View::Rendering::NullTemplate]
        #   the layout associated with the given context or a `NullTemplate` if
        #   it can't be found.
        #
        # @raise [Lotus::View::MissingFormatError] if the given context doesn't
        #   have the :format key
        #
        # @api private
        # @since 0.1.0
        def resolve(context)
          @registry.fetch(format(context)) { NullTemplate.new }
        end

        protected
        def prepare!
          templates.each do |template|
            @registry.merge! template.format => template
          end
          @registry.any? or raise MissingTemplateLayoutError.new(@view)
        end

        def templates
          TemplatesFinder.new(@view).find
        end

        def format(context)
          context.fetch(:format) { raise MissingFormatError }
        end
      end
    end
  end
end
