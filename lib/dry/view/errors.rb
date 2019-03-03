module Dry
  class View
    class TemplateNotFoundError < StandardError
      def initialize(template_name, lookup_paths)
        msg = [
          "Template `#{template_name}` could not be found in paths:",
          lookup_paths.map { |path| " - #{path.to_s}"}
        ].join("\n\n")

        super(msg)
      end
    end
  end
end
