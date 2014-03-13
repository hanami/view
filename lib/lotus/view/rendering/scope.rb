require 'lotus/view/rendering/layout_scope'
require 'lotus/view/rendering/template'
require 'lotus/view/rendering/partial'

module Lotus
  module View
    module Rendering
      class Scope < LayoutScope
        def initialize(view, locals = {})
          @view, @locals = view, locals
        end

        def format
          locals[:format]
        end

        protected
        def method_missing(m)
          if @view.respond_to?(m)
            @view.__send__ m
          elsif @locals.key?(m)
            @locals[m]
          else
            super
          end
        end
      end
    end
  end
end
