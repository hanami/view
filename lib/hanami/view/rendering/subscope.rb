# frozen_string_literal: true

require "hanami/view/rendering/scope"
require "hanami/view/rendering/options"

module Hanami
  module View
    module Rendering
      # Rendering subscope
      #
      # @since 1.1.1
      # @api private
      #
      # @see Hanami::View::Rendering::Scope
      class Subscope < Scope
        # Implements "respond to" logic
        #
        # @return [TrueClass,FalseClass]
        #
        # @since 1.1.1
        # @api private
        #
        # @see http://ruby-doc.org/core/Object.html#method-i-respond_to_missing-3F
        def respond_to_missing?(m, _include_all)
          @locals.key?(m)
        end

        protected

        # @since 1.1.1
        # @api private
        def method_missing(m, *args, &block)
          ::Hanami::View::Escape.html(
            # FIXME: this isn't compatible with Hanami 2.0, as it extends a view
            # that we want to be frozen in the future
            #
            # See https://github.com/hanami/view/issues/130#issuecomment-319326236
            if @locals.key?(m)
              @locals[m]
            else
              super
            end
          )
        end

        private

        # @since 1.1.1
        # @api private
        def _options(options)
          Options.build(options, locals, format)
        end
      end
    end
  end
end
