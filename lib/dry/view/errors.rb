module Dry
  class View
    # Error raised when template could not be found within a view's configured
    # paths
    class TemplateNotFoundError < StandardError
      def initialize(template_name, lookup_paths)
        msg = [
          "Template `#{template_name}` could not be found in paths:",
          lookup_paths.map { |path| " - #{path}"}
        ].join("\n\n")

        super(msg)
      end
    end
  end
end
