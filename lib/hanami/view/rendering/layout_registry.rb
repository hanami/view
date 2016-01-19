require 'hanami/view/rendering/null_template'
require 'hanami/view/rendering/templates_finder'

module Hanami
  module View
    module Rendering
      # Holds the references of all the registered layouts.
      # As now the registry is unique at the level of the framework.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::Layout::ClassMethods#registry
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
        # @return [Hanami::Layout, Hanami::View::Rendering::NullTemplate]
        #   the layout associated with the given context or a `NullTemplate` if
        #   it can't be found.
        #
        # @raise [Hanami::View::MissingFormatError] if the given context doesn't
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
