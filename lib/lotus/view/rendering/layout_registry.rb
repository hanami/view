require 'lotus/view/rendering/null_template'
require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      # Holds the references of all the registered layouts.
      # As now the registry is unique at the level of the framework.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Layout::ClassMethods#registry
      class LayoutRegistry < ::Hash
        # Initialize the registry
        #
        # @param view [Class] the view
        #
        # @api private
        # @since 0.1.0
        def initialize(view)
          super()

          @view = view
          prepare!
        end

        # Returns the layout for the given context.
        #
        # @param context [Hash] the rendering context
        #
        # @return [Lotus::Layout, Lotus::View::Rendering::NullTemplate]
        #   the layout associated with the given context or a `NullTemplate` if
        #   it can't be found.
        #
        # @api private
        # @since 0.1.0
        def resolve(context)
          fetch(context[:format], NullTemplate.new)
        end

        protected
        def prepare!
          templates.each do |template|
            merge! template.format => template
          end
        end

        def templates
          TemplatesFinder.new(@view).find
        end
      end
    end
  end
end
