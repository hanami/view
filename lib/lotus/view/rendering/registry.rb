require 'pathname'
require 'tilt'
require 'lotus/view/template/finder'

module Lotus
  module View
    module Rendering
      # TODO extract into a separate file
      # TODO eventually make it a singleton
      class NullView
        def render(locals)
        end
      end

      class Registry
        def initialize(view)
          @view     = view
          @registry = _prepare
        end

        def resolve(context)
          # TODO instead of using OR, set this a `registry` default
          registry[context.format] || NullView.new
        end

        private
        attr_reader :view, :registry

        def views
          view.subclasses + [ view ]
        end

        def _prepare
          {}.tap do |result|
            Lotus::View.formats.each do |format|
              result[format] = _view_for(format)
            end
          end
        end

        def _view_for(format)
          v = views.find {|view| view.formats.include?(format) }
          template = _template_for(v, format)

          # TODO remove this Nil check
          v.new(template) if template
        end

        def _template_for(view, format)
          Lotus::View::Template::Finder.new(view, format).find
        end
      end
    end
  end
end
