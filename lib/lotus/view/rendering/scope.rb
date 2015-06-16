require 'lotus/utils/escape'
require 'lotus/view/rendering/layout_scope'
require 'lotus/view/rendering/template'
require 'lotus/view/rendering/partial'

module Lotus
  module View
    module Rendering
      # Rendering scope
      #
      # @since 0.1.0
      #
      # @see Lotus::View::Rendering::LayoutScope
      class Scope < LayoutScope
        # Initialize the scope
        #
        # @param view [Class] the view
        # @param locals [Hash] a set of objects available during the rendering
        # @option locals [Symbol] :format the requested format
        #
        # @api private
        # @since 0.1.0
        def initialize(view, locals = {})
          @view, @locals, @layout = view, locals, layout
        end

        # Returns an inspect String
        #
        # @return [String] inspect String (contains classname, objectid in hex, available ivars)
        #
        # @since 0.3.0
        def inspect
          base = "#<#{ self.class }: #{'%x' % (self.object_id << 1)}"
          base << " @view=\"#{@view}\"" if @view
          base << " @locals=\"#{@locals}\"" if @locals
          base << ">"
        end

        # Returns the requested format.
        #
        # @return [Symbol] the requested format (eg. :html, :json, :xml, etc..)
        #
        # @since 0.1.0
        def format
          locals[:format]
        end

        # Implements "respond to" logic
        #
        # @return [TrueClass,FalseClass]
        #
        # @since 0.3.0
        # @api private
        #
        # @see http://ruby-doc.org/core/Object.html#method-i-respond_to_missing-3F
        def respond_to_missing?(m, include_all)
          @view.respond_to?(m) ||
            @locals.key?(m)
        end

        protected
        def method_missing(m, *args, &block)
          ::Lotus::View::Escape.html(
            if @view.respond_to?(m)
              @view.__send__ m, *args, &block
            elsif @locals.key?(m)
              @locals[m]
            else
              super
            end
          )
        end

        private

        # @since 0.4.2
        # @api private
        def layout
          if @view.class.respond_to?(:layout)
            @view.class.layout.new(self, "")
          else
            nil
          end
        end
      end
    end
  end
end
