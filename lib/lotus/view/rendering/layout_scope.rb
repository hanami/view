module Lotus
  module View
    module Rendering
      class LayoutScope
        def initialize(layout, scope)
          @layout, @scope = layout, scope
        end

        def render(options)
          renderer(options).render
        end

        def format
          @scope.format
        end

        def view
          @view || @scope.view
        end

        def locals
          @locals || @scope.locals
        end

        protected
        def method_missing(m)
          begin
            @scope.__send__ m
          rescue
            @layout.__send__ m
          end
        end

        def renderer(options)
          if options[:partial]
            Rendering::Partial
          elsif options[:template]
            Rendering::Template
          end.new(view, _options(options))
        end

        private
        def _options(options)
          options.dup.tap do |opts|
            opts.merge!(format: format)
            opts[:locals] ||= {}
            opts[:locals].merge!(locals)
          end
        end
      end
    end
  end
end
