require 'lotus/view/rendering/templates_finder'

module Lotus
  module View
    module Rendering
      class TemplateFinder < TemplatesFinder
        def initialize(view, options)
          super(view)
          @options = options
        end

        def find
          super.first
        end

        protected
        def template_name
          @options[:template]
        end

        def format
          @options[:format]
        end
      end
    end
  end
end
