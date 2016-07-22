module Hanami
  module View
    module Rendering
      # @since 0.7.0
      # @api private
      class PartialFile
        attr_reader :key, :format, :template

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
