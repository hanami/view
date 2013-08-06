require 'lotus/view/rendering/template_finder'

module Lotus
  module View
    module Rendering
      class Template
        def initialize(view, options)
          @view, @options = view, options
        end

        def render
          template.render(scope)
        end

        protected
        def template
          TemplateFinder.new(@view.class, @options).find
        end

        def scope
          Scope.new(@view, @options[:locals])
        end
      end
    end
  end
end
