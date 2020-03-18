# frozen_string_literal: true

require "pathname"

module Hanami
  class View
    class << self
      def [](slice_name)
        slice = Hanami.application.slices[slice_name]

        # TODO: "web/templates" should be configurable on the application
        # FIXME: should slice.root always be a pathname?
        templates_path = Pathname(slice.root).join("web/templates").to_s

        klass = Class.new(self) do
          config.paths = [templates_path]
          config.layouts_dir = templates_path
          config.layout = "application"
        end

        klass.define_singleton_method :inherited do |subclass|
          super(subclass)

          unless subclass.superclass == klass
            subclass.config.template = template_name(subclass, slice)
          end
        end

        klass
      end

      private

      def template_name(view, slice)
        # FIXME: the "views" prefix thing should be configurable?
        slice.inflector.underscore(view.name)
          .sub(/^#{slice.namespace_path}\//, "")
          .sub(/^views?\//, "")
      end
    end
  end
end
