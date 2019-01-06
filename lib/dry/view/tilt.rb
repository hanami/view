require "dry/core/cache"
require "tilt"

module Dry
  module View
    module Tilt
      extend Dry::Core::Cache

      class << self
        def default_mapping
          ::Tilt.default_mapping
        end

        def with_mapping(mapping)
          fetch_or_store(mapping) {
            if mapping.any?
              build_mapping(mapping)
            else
              default_mapping
            end
          }
        end

        private

        def build_mapping(mapping)
          default_mapping.dup.tap do |new_mapping|
            mapping.each do |extension, template_class|
              new_mapping.register template_class, extension
            end
          end
        end
      end
    end
  end
end
