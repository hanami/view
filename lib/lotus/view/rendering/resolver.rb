module Lotus
  module View
    module Rendering
      class Resolver
        def initialize(view)
          @view = view
        end

        def resolve(context)
          @view.templates.first
        end
      end
    end
  end
end
