require 'hanami/utils/escape'
require 'hanami/view/rendering/layout_scope'
require 'hanami/view/rendering/template'
require 'hanami/view/rendering/partial'

module Hanami
  module View
    module Rendering
      # Rendering scope
      #
      # @since 0.1.0
      #
      # @see Hanami::View::Rendering::LayoutScope
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
          @view   = view
          @locals = locals
          @layout = layout
          @scope  = nil
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
          # FIXME: this isn't compatible with Hanami 2.0, as it extends a view
          # that we want to be frozen in the future
          #
          # See https://github.com/hanami/view/issues/130#issuecomment-319326236
          @view.respond_to?(m, include_all) ||
            @locals.key?(m)
        end

        protected
        # @api private
        def method_missing(m, *args, &block)
          ::Hanami::View::Escape.html(
            # FIXME: this isn't compatible with Hanami 2.0, as it extends a view
            # that we want to be frozen in the future
            #
            # See https://github.com/hanami/view/issues/130#issuecomment-319326236
            if @view.respond_to?(m, true)
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
