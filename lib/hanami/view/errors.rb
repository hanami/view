module Hanami
  module View
    # @since 0.5.0
    class Error < ::StandardError
    end

    # Missing template error
    #
    # This is raised at the runtime when Hanami::View cannot find a template for
    # the requested format.
    #
    # We can't raise this error during the loading phase, because at that time
    # we don't know if a view implements its own rendering policy.
    # A view is allowed to override `#render`, and this scenario can make the
    # presence of a template useless. One typical example is the usage of a
    # serializer that returns the output string, without rendering a template.
    #
    # @since 0.1.0
    class MissingTemplateError < Error
      def initialize(template, format)
        super("Can't find template '#{ template }' for '#{ format }' format.")
      end
    end

    # Missing format error
    #
    # This is raised at the runtime when rendering context lacks of the :format
    # key.
    #
    # @since 0.1.0
    #
    # @see Hanami::View::Rendering#render
    class MissingFormatError < Error
    end

    # Missing template layout error
    #
    # This is raised at the runtime when Hanami::Layout cannot find it's template.
    #
    # @since 0.5.0
    class MissingTemplateLayoutError < Error
      def initialize(template)
        super("Can't find layout template '#{ template }'")
      end
    end
  end
end
