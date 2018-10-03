module Hanami
  module View
    module Rendering
      # Null Object pattern for view
      #
      # It's used when a layout is rendered direcly for testing purposes
      #
      # @api private
      # @since x.x.x
      class NullView
        # Render the layout template
        #
        # @return [String] an empty string
        #
        # @api private
        # @since x.x.x
        #
        # @see Hanami::Layout#render
        # @see Hanami::View::Rendering#render
        def render
          ""
        end
      end
    end
  end
end
