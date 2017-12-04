# frozen_string_literal: true

require "hanami/utils/hash"

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
          Utils::Hash.deep_dup(options).tap do |opts|
            opts[:format] = format
            opts[:locals] = locals
            opts[:locals].merge!(options.fetch(:locals) { ::Hash.new }).merge!(format: format)
          end
        end
      end
    end
  end
end
