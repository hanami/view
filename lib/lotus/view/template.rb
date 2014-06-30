require 'tilt'

module Lotus
  module View
    # A logic-less template.
    #
    # @since 0.1.0
    class Template
      def initialize(template)
        @_template = Tilt.new(template)
      end

      # Returns the format that the template handles.
      #
      # @return [Symbol] the format name
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/view'
      #
      #   template = Lotus::View::Template.new('index.html.erb')
      #   template.format # => :html
      def format
        @_template.basename.match(/\.([^.]+)/).captures.first.to_sym
      end

      # Render the template within the context of the given scope.
      #
      # @param scope [Lotus::View::Scope] the rendering scope
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View::Scope
      def render(scope, &blk)
        @_template.render(scope, {}, &blk)
      end
    end
  end
end
