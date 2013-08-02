require 'lotus/view/rendering/locals'
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
          TemplateFinder.new(view.class, options[:template]).find
        end

        def locals
          Locals.new(options[:locals])
        end

        def scope
          Scope.new(view, locals)
        end

        private
        attr_reader :view, :options
      end
    end
  end
end
