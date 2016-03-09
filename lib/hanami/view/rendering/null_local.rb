require 'hanami/utils/basic_object'

module Hanami
  module View
    module Rendering
      # Null local
      #
      # @since x.x.x
      #
      # @see Hanami::View::Rendering#local
      class NullLocal < Utils::BasicObject
        # @since x.x.x
        # @api private
        TO_STR = "".freeze

        # @since x.x.x
        # @api private
        def initialize(local)
          @local = local
        end

        # @since x.x.x
        def all?
          false
        end

        # @since x.x.x
        def any?
          false
        end

        # @since x.x.x
        def empty?
          true
        end

        # @since x.x.x
        def nil?
          true
        end

        # @since x.x.x
        # @api private
        def to_str
          TO_STR
        end

        # @since x.x.x
        # @api private
        def method_missing(m, *)
          if m.match(/\?\z/)
            false
          else
            self.class.new("#{ @local }.#{ m }")
          end
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
