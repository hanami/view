require 'lotus/view/rendering/layout_registry'
require 'lotus/view/rendering/view_finder'
require 'lotus/view/rendering/null_view'

module Lotus
  module View
    module Rendering
      class Registry < LayoutRegistry
        def resolve(context, locals)
          view, template = fetch(context[:format], NullView)
          view.new(template, locals.merge(context))
        end

        protected
        def prepare!
          templates.each do |template|
            merge! template.format => [ _view_for(template), template ]
          end
        end

        def _view_for(template)
          ViewFinder.new(@view).find(template)
        end
      end
    end
  end
end
