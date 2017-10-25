require 'hanami/utils/string'

module Hanami
  module View
    module Rendering
      # @since 0.2.0
      # @api private
      class TemplateName
        # @since 0.2.0
        # @api private
        NAMESPACE_SEPARATOR = '::'.freeze

        # @since 0.2.0
        # @api private
        def initialize(name, namespace)
          @name = name
          compile!(namespace)
        end

        # @since 0.2.0
        # @api private
        def to_s
          @name
        end

        private
        # @since 0.2.0
        # @api private
        def compile!(namespace)
          tokens(namespace) {|token| replace!(token) }
          @name = Utils::String.underscore(@name)
        end

        # @since 0.2.0
        # @api private
        def tokens(namespace)
          namespace.to_s.split(NAMESPACE_SEPARATOR).each do |token|
            yield token
          end
        end

        # @since 0.2.0
        # @api private
        def replace!(token)
          @name.gsub!(%r{\A#{ token }#{ NAMESPACE_SEPARATOR }}, '')
        end
      end
    end
  end
end
