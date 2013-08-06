module Lotus
  module View
    module Rendering
      class LayoutScope
        def initialize(layout, scope)
          @layout, @scope = layout, scope
        end

        def format
          @scope.format
        end

        protected
        def method_missing(m, *args)
          begin
            @scope.__send__ m
          rescue
            @layout.__send__ m
          end
        end
      end
    end
  end
end
