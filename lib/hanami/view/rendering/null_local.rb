require 'hanami/utils/basic_object'

module Hanami
  module View
    module Rendering
      # Null local
      #
      # @since 0.7.0
      #
      # @see Hanami::View::Rendering#local
      class NullLocal < Utils::BasicObject
        # @since 0.7.0
        # @api private
        TO_STR = "".freeze

        # @since 0.7.0
        # @api private
        def initialize(local)
          @local = local
        end

        # @since 0.7.0
        # @api private
        def all?
          false
        end

        # @since 0.7.0
        # @api private
        def any?
          false
        end

        # @since 0.7.0
        # @api private
        def empty?
          true
        end

        # @since 0.7.0
        # @api private
        def nil?
          true
        end

        # @since 0.7.0
        # @api private
        def to_str
          TO_STR
        end

        # @since 0.8.0
        # @api private
        alias to_s to_str

        # @since 0.7.0
        # @api private
        def method_missing(m, *)
          if m.match(/\?\z/)
            false
          else
            self.class.new("#{ @local }.#{ m }")
          end
        end

        private

        # @since 0.7.0
        # @api private
        def respond_to_missing?(method_name, include_all)
          true
        end

        # @since 0.7.0
        # @api private
        def __inspect
          " :#{ @local }"
        end
      end
    end
  end
end
