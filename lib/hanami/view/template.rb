require 'tilt'

module Hanami
  module View
    # A logic-less template.
    #
    # @since 0.1.0
    class Template
      def initialize(template, encoding = Encoding::UTF_8)
        # NOTE disable_escape: true is for Slim compatibility
        # See https://github.com/hanami/assets/issues/36
        @_template = Tilt.new(template, nil, default_encoding: encoding, disable_escape: true)
      end

      # Returns the format that the template handles.
      #
      # @return [Symbol] the format name
      #
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/view'
      #
      #   template = Hanami::View::Template.new('index.html.erb')
      #   template.format # => :html
      def format
        @_template.basename.match(/\.([^.]+)/).captures.first.to_sym
      end

      # Render the template within the context of the given scope.
      #
      # @param scope [Hanami::View::Scope] the rendering scope
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      #
      # @see Hanami::View::Scope
      def render(scope, &blk)
        @_template.render(scope, {}, &blk)
      end
    end
  end
end
