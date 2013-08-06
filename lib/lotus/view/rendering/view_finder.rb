module Lotus
  module View
    module Rendering
      class ViewFinder
        def initialize(view)
          @view = view
        end

        def find(template)
          @view.subclasses.find {|v| v.format == template.format } || @view
        end
      end
    end
  end
end
