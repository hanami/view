require 'lotus/view/partial'

module Lotus
  module View
    module Rendering
      class Scope
        def initialize(view)
          @view = view
        end

        def render(options)
          if options[:partial]
            Partial.new(view, options).render
          end
        end

        protected
        def method_missing(m, *args)
          view.send m, *args
        end

        private
        attr_reader :view
      end
    end
  end
end
