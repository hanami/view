require 'lotus/view/rendering/view_finder'
require 'lotus/view/rendering/template_finder'
require 'lotus/view/rendering/null_view'

module Lotus
  module View
    module Rendering
      class Registry < ::Hash
        def initialize(view)
          super()

          @view = view
          prepare!
        end

        def resolve(context, locals)
          v, t = fetch(context[:format], NullView)
          v.new(t, locals)
        end

        protected
        attr_reader :view

        def prepare!
          templates.each do |template|
            merge! template.format => [ _view_for(template), template ]
          end
        end

        def templates
          TemplateFinder.new(view).find
        end

        def _view_for(template)
          ViewFinder.new(view).find(template)
        end
      end
    end
  end
end
