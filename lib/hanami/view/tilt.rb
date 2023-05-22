require "tilt"

module Hanami
  class View
    # @api private
    module Tilt
      Mapping = ::Tilt.default_mapping.dup.tap { |mapping|
        # If "slim" has been required before "hanami/view", unregister Slim's non-lazy registered
        # template, so our own template adapter (using register_lazy below) can take precedence.
        mapping.unregister "slim"

        # Register our own ERB template.
        mapping.register_lazy "Hanami::View::ERB::Template", "hanami/view/erb/template", "erb", "rhtml"

        # Register ERB templates for Haml and Slim that set the `use_html_safe: true` option.
        #
        # Our template namespaces below have the "Adapter" suffix to work around a bug in Tilt's
        # `Mapping#const_defined?`, which (if slim was already required) would receive
        # "Hanami::View::Slim::Template" and return `Slim::Template`, which is the opposite of what
        # we want.
        mapping.register_lazy "Hanami::View::Tilt::HamlAdapter::Template", "hanami/view/tilt/haml_adapter", "haml"
        mapping.register_lazy "Hanami::View::Tilt::SlimAdapter::Template", "hanami/view/tilt/slim_adapter", "slim"
      }

      class << self
        def [](path, mapping, options)
          with_mapping(mapping).new(path, options)
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
