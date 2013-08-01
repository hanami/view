module Lotus
  module View
    module Rendering
      class Scope
        def initialize(view)
          @view = view
        end

        protected
        def method_missing(m, *args)
          @view.send m, *args
        end
      end
    end
  end
end
