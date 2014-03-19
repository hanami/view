module Lotus
  module View
    module Rendering
      # Find a view
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View::Rendering::Registry
      class ViewFinder
        # Initialize a finder
        #
        # @param view [Class] the superclass view
        #
        # @api private
        # @since 0.1.0
        def initialize(view)
          @view = view
        end

        # Find a view for the given template.
        # It looks up for the current view and its subclasses.
        #
        # @param template [Lotus::View::Template] a template to be associated
        #   to a view
        #
        # @return [Class] a view associated with the given template
        #
        # @api private
        # @since 0.1.0
        def find(template)
          @view.subclasses.find {|v| v.format == template.format } || @view
        end
      end
    end
  end
end
