module Lotus
  module View
    module Rendering
      def render(context)
        body.render(nil, context)
      end
    end
  end
end
