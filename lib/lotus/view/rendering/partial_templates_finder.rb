require 'lotus/view/template'

module Lotus
  module View
    module Rendering
      # Find templates for a view
      #
      # @api private
      # @since 0.1.0
      #
      # @see View::Template
      class PartialTemplatesFinder
        def find_partials(path)
          _find_partials(path).map do |template|
            path_name = Pathname(template)
            partial_path, partial_base_name = Pathname(template).relative_path_from(path).split
            partial_base_parts = partial_base_name.to_s.split('.')
            partial_template_name = "#{partial_path}#{::File::SEPARATOR}#{partial_base_parts[0]}"
            partial_format = partial_base_parts[1]
            [partial_template_name, partial_format, View::Template.new(template)]
          end
        end

        private

        def _find_partials(path)
          # TODO: Freeze the string constants
          Dir.glob("#{ [path, '**', '_*'].join(::File::SEPARATOR) }.#{ '*' }.#{ '*' }")
        end
      end
    end
  end
end

