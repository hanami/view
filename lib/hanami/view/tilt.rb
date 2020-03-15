# frozen_string_literal: true

require "dry/core/cache"
require "tilt"

module Hanami
  class View
    # @api private
    module Tilt
      extend Dry::Core::Cache

      class << self
        def [](path, mapping, **options)
          ext = File.extname(path).sub(/^./, "").to_sym
          activate_adapter ext

          with_mapping(mapping).new(path, **options)
        end

        def default_mapping
          ::Tilt.default_mapping
        end

        def register_adapter(ext, adapter)
          adapters[ext] = adapter
        end

        def deregister_adapter(ext)
          adapters.delete(ext)
        end

        private

        def adapters
          @adapters ||= {}
        end

        def activate_adapter(ext)
          fetch_or_store(:adapter, ext) {
            adapter = adapters[ext]
            return unless adapter

            *requires, error_message = adapter.requirements

            begin
              requires.each(&method(:require))
            rescue LoadError => e
              raise e, "#{e.message}\n\n#{error_message}"
            end

            adapter.activate
          }
        end

        def with_mapping(mapping)
          fetch_or_store(:mapping, mapping) {
            if mapping.any?
              build_mapping(mapping)
            else
              default_mapping
            end
          }
        end

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

require_relative "tilt/erb"
require_relative "tilt/haml"
