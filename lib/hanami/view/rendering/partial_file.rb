module Hanami
  module View
    module Rendering
      # @since 0.7.0
      # @api private
      class PartialFile
        # @since 0.7.0
        # @api private
        attr_reader :key

        # @since 0.7.0
        # @api private
        attr_reader :format

        # @since 0.7.0
        # @api private
        attr_reader :template

        # @since 0.7.0
        # @api private
        def initialize(key, format, template)
          @key      = key
          @format   = format
          @template = template
        end
      end
    end
  end
end
