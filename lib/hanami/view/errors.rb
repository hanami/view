# frozen_string_literal: true

module Hanami
  class View
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
      def initialize(template_name, lookup_paths)
        msg = [
          "Template +#{template_name}+ could not be found in paths:",
          lookup_paths.map { |path| " - #{path}" }
        ].join("\n\n")

        super(msg)
      end
    end
  end
end
