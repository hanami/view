require 'lotus/utils/string'

module Lotus
  module View
    module Rendering
      # @since 0.2.0
      class TemplateName
        NAMESPACE_SEPARATOR = '::'.freeze

        def initialize(name, namespace)
          @name = name
          compile!(namespace)
        end

        def to_s
          @name
        end

        private
        def compile!(namespace)
          tokens(namespace) {|token| replace!(token) }
          @name = Utils::String.new(@name).underscore
        end

        def tokens(namespace)
          namespace.to_s.split(NAMESPACE_SEPARATOR).each do |token|
            yield token
          end
        end

        def replace!(token)
          @name.gsub!(%r{\A#{ token }#{ NAMESPACE_SEPARATOR }}, '')
        end
      end
    end
  end
end
