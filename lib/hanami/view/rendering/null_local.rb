require 'hanami/utils/basic_object'

module Hanami
  module View
    module Rendering
      # Null local
      #
      # @since x.x.x
      #
      # @see Hanami::View::Rendering::LayoutScope
      class NullLocal < Utils::BasicObject
        # @since x.x.x
        # @api private
        def initialize(local)
          @local = local
        end

        # @since x.x.x
        # @api private
        def method_missing(*)
        end

        # @since x.x.x
        def nil?
          true
        end

        private

        # @since x.x.x
        # @api private
        def respond_to_missing?(method_name, include_all)
          true
        end

        # @since x.x.x
        # @api private
        def __inspect
          " :#{ @local }"
        end
      end
    end
  end
end
