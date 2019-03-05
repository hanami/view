module Dry
  class View
    # Error raised with paths are not configured
    #
    # @api private
    class UndefinedPathsError < StandardError
      def initialize(*)
        super("no +paths+ configured")
      end
    end

    # Error raised when template name is not configured
    #
    # @api private
    class UndefinedTemplateError < StandardError
      def initialize(*)
        super("no +template+ configured")
      end
    end

    # Error raised when template could not be found within a view's configured
    # paths
    #
    # @api private
    class TemplateNotFoundError < StandardError
      def initialize(template_name, lookup_paths)
        msg = [
          "Template +#{template_name}+ could not be found in paths:",
          lookup_paths.map { |path| " - #{path}"}
        ].join("\n\n")

        super(msg)
      end
    end
  end
end
