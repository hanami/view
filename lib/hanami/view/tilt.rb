# frozen_string_literal: true

require "tilt"

module Hanami
  class View
    # @api private
    module Tilt
      Mapping = ::Tilt.default_mapping.dup.tap { |mapping|
        mapping.register_lazy "Hanami::View::ERB::Template", "hanami/view/erb/template", "erb", "rhtml"
        mapping.register_lazy "Hanami::View::Haml::Template", "hanami/view/haml/template", "haml"
      }

      class << self
        def [](path, mapping, options)
          with_mapping(mapping).new(path, options)
        end

        def register_adapter(ext, adapter)
          adapters[ext] = adapter
        end

        def deregister_adapter(ext)
          adapters.delete(ext)
        end

        private

        def with_mapping(mapping)
          View.cache.fetch_or_store(:tilt_mapping, mapping) {
            if mapping.any?
              build_mapping(mapping)
            else
              Mapping
            end
          }
        end

        def build_mapping(mapping)
          Mapping.dup.tap do |new_mapping|
            mapping.each do |extension, template_class|
              new_mapping.register template_class, extension
            end
          end
        end
      end
    end
  end
end
