require 'lotus/view/rendering/template'
require 'lotus/view/rendering/partial'

module Lotus
  module View
    module Rendering
      class Scope
        def initialize(view, locals = {})
          @view = view
          prepare!(locals)
        end

        def render(options)
          if options[:partial]
            Rendering::Partial.new(view, options).render
          elsif options[:template]
            Rendering::Template.new(view, options).render
          end
        end

        protected
        def method_missing(m, *args)
          view.send m, *args
        end

        def prepare!(locals)
          view.extend(locals.modulize) if locals.any?
        end

        private
        attr_reader :view
      end
    end
  end
end
