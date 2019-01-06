require "dry/core/cache"
require "tilt"

module Dry
  module View
    module Tilt
      extend Dry::Core::Cache

      module_function

      def default
        ::Tilt.default_mapping
      end

      def with_mapping(mapping)
        fetch_or_store(mapping) {
          default.dup.tap do |new_mapping|
            mapping.each do |extension, template_class|
              new_mapping.register template_class, extension
            end
          end
        }
      end
    end
  end
end
