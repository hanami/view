module Lotus
  module View
    module Rendering
      # Null Object pattern for Layout.
      # It's used when a view doesn't require a layout.
      #
      # @api private
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #       layout false
      #     end
      #   end
      #
      #   # In this scenario we will use a `NullLayout`.
      class NullLayout

        # Initialize a layout
        #
        # @param scope [Lotus::View::Rendering::Scope] view rendering scope
        # @param rendered [String] the output of the view rendering process
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::Layout#initialize
        # @see Lotus::View::Rendering#render
        def initialize(scope, rendered)
          @rendered = rendered
        end

        # Render the layout
        #
        # @return [String] the output of the rendering process
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::Layout#render
        # @see Lotus::View::Rendering#render
        def render
          @rendered
        end
      end
    end
  end
end
