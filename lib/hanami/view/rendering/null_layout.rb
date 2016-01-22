module Hanami
  module View
    module Rendering
      # Null Object pattern for Layout.
      # It's used when a view doesn't require a layout.
      #
      # @api private
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/view'
      #
      #   module Articles
      #     class Show
      #       include Hanami::View
      #       layout false
      #     end
      #   end
      #
      #   # In this scenario we will use a `NullLayout`.
      class NullLayout

        # Initialize a layout
        #
        # @param scope [Hanami::View::Rendering::Scope] view rendering scope
        # @param rendered [String] the output of the view rendering process
        #
        # @api private
        # @since 0.1.0
        #
        # @see Hanami::Layout#initialize
        # @see Hanami::View::Rendering#render
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
        # @see Hanami::Layout#render
        # @see Hanami::View::Rendering#render
        def render
          @rendered
        end
      end
    end
  end
end
