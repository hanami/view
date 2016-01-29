module Hanami
  module View
    module Rendering
      # @since x.x.x
      # @api private
      class PartialFile
        attr_reader :key, :format, :template

        # @since x.x.x
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
