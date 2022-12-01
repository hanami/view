# frozen_string_literal: true

module Hanami
  class View
    # @since 2.0.0
    # @api public
    class Error < StandardError
    end

    # Error raised when critical settings are not configured
    #
    # @api private
    class UndefinedConfigError < StandardError
      def initialize(key)
        super("no +#{key}+ configured")
      end
    end

    # Error raised when template could not be found within a view's configured
    # paths
    #
    # @api private
    class TemplateNotFoundError < StandardError
      def initialize(template_name, format, lookup_paths)
        msg = [
          "Template +#{template_name}+ for format +#{format}+ could not be found in paths:",
          lookup_paths.map { |path| " - #{path}" }
        ].join("\n\n")

        super(msg)
      end
    end

    # Error raised when layout could not be found within a view's configured
    # paths
    #
    # @api private
    class LayoutNotFoundError < StandardError
      def initialize(layout_name, lookup_paths)
        msg = [
          "Layout +#{layout_name}+ could not be found in paths:",
          lookup_paths.map { |path| " - #{path}" }
        ].join("\n\n")

        super(msg)
      end
    end
  end
end
