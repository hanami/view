module Lotus
  module View
    module Rendering
      class NullLayout
        def initialize(scope, rendered)
          @rendered = rendered
        end

        def render
          @rendered
        end
      end
    end
  end
end
