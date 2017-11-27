require 'hanami/view/rendering/view_scope'
require 'hanami/view/rendering/options'

module Hanami
  module View
    module Rendering
      # Rendering subscope
      #
      # @since x.x.x
      #
      # @see Hanami::View::Rendering::ViewScope
      class Subscope < ViewScope

        protected

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

        # @api private
        def _options(options)
          Options.build(options, locals, format)
        end
      end
    end
  end
end
