require 'lotus/view/template'

module Lotus
  module View
    module Rendering
      # Find partial templates in the file system
      #
      # @api private
      # @since x.x.x
      #
      # @see View::Template
      class PartialTemplatesFinder
        # Search pattern for partial file names
        #
        # @api private
        # @since x.x.x
        PARTIAL_PATTERN    = '_*'.freeze

        # Initialize a configuration instance
        #
        # @return [Array] array of arrays containing partial template name,
        # format and a newly created View::Template
        #
        # @since x.x.x
        def self.find_partials(path)
          _find_partials(path).map do |template|
            path_name = Pathname(template)
            partial_path, partial_base_name = Pathname(template).relative_path_from(path).split
            partial_base_parts = partial_base_name.to_s.split('.')
            ["#{partial_path}#{::File::SEPARATOR}#{partial_base_parts[0]}", partial_base_parts[1], View::Template.new(template)]
          end
        end

        # Copy the configuration for the given action
        #
        # @param path [String] the path under which we should search for partials
        #
        # @return [Array] an array of strings for each matching partial found
        #
        # @since x.x.x
        # @api private
        def self._find_partials(path)
          Dir.glob("#{ [path, TemplatesFinder::RECURSIVE, PARTIAL_PATTERN].join(::File::SEPARATOR) }.#{TemplatesFinder::FORMAT}.#{TemplatesFinder::ENGINES}")
        end
      end
    end
  end
end

