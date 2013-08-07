require 'lotus/view/template'

module Lotus
  module View
    module Rendering
      class TemplatesFinder
        FORMAT = '*'.freeze

        def initialize(view)
          @view = view
        end

        def find
          Dir.glob( "#{ [root, template_name].join(separator) }.#{ format }.#{ engines }" ).map do |template|
            View::Template.new template
          end
        end

        protected
        def template_name
          @view.template
        end

        def root
          @view.root
        end

        def separator
          ::File::SEPARATOR
        end

        def format
          FORMAT
        end

        def engines
          "{#{ Tilt.mappings.keys.join(',') }}"
        end
      end
    end
  end
end
