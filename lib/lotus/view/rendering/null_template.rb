module Lotus
  module View
    module Rendering
      class NullTemplate
        def render(scope, locals = {}, &blk)
          blk.call
        end
      end
    end
  end
end
