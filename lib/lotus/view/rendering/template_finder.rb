require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      class TemplateFinder < TemplatesFinder
        def initialize(view, template_name)
          super(view)
          @template_name = template_name
        end

        def find
          super.first
        end

        protected
        def template_name
          @template_name
        end
      end
    end
  end
end
