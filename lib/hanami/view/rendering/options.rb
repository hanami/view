# frozen_string_literal: true

module Hanami
  module View
    module Rendering
      # Rendering options
      #
      # @since 1.1.1
      # @api private
      class Options
        # @since 1.1.1
        # @api private
        def self.build(options, locals, format)
          options.dup.tap do |opts|
            opts[:format] = format
            opts[:locals] = locals
            opts[:locals].merge!(options.fetch(:locals) { ::Hash.new }).merge!(format: format)
          end
        end
      end
    end
  end
end
