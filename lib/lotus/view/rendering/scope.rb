require 'lotus/view/rendering/template'
require 'lotus/view/rendering/partial'

module Lotus
  module View
    module Rendering
      class Scope
        attr_reader :locals

        def initialize(view, locals = {})
          @view, @locals = view, locals
        end

        def render(options)
          renderer(options).render
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

        def renderer(options)
          if options[:partial]
            Rendering::Partial
          elsif options[:template]
            Rendering::Template
          end.new(@view, _options(options))
        end

        private
        def _options(options)
          options.dup.tap do |opts|
            opts.merge!(format: @locals[:format])
            opts[:locals] ||= {}
            opts[:locals].merge!(@locals)
          end
        end
      end
    end
  end
end
