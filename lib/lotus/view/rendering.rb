module Lotus
  module View
    module Rendering
      def render(context)
        template.render(nil, context)
      end
    end
  end
end
